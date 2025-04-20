import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CreateAppointmentPage extends StatefulWidget {
  const CreateAppointmentPage({super.key});

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseClient = Supabase.instance.client;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  bool _isLoading = false;

  final List<String> _appointmentTypes = [
    'Checkup',
    'Consultation',
    'STI/STD Testing',
    'Treatment',
    'Follow-up',
    'Others'
  ];

  String? _selectedAppointmentType;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    // Get the current date
    final DateTime now = DateTime.now();
    
    // Calculate the next business day (skipping weekends)
    DateTime initialDate = now.add(const Duration(days: 1));
    
    // If the initial date is a weekend, move to Monday
    if (initialDate.weekday == DateTime.saturday) {
      initialDate = initialDate.add(const Duration(days: 2));
    } else if (initialDate.weekday == DateTime.sunday) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      selectableDayPredicate: (DateTime date) {
        // Disable weekends
        return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.red),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.red),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format time to HH:MM format
      final String hour = picked.hour.toString().padLeft(2, '0');
      final String minute = picked.minute.toString().padLeft(2, '0');
      
      setState(() {
        _timeController.text = '$hour:$minute';
      });
    }
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        // Combine date and time
        final appointmentDateTime = '${_dateController.text} ${_timeController.text}:00';
        
        // Create the appointment data
        final appointmentData = {
          'patient_id': user.id,
          'appointment_date': appointmentDateTime,
          'appointment_type': _selectedAppointmentType,
          'purpose': _purposeController.text,
          'status': 'Pending', // Default status
        };

        // Insert into database
        await _supabaseClient.from('appointment').insert(appointmentData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment created successfully')),
          );
          
          // Navigate back to appointments page
          Navigator.pushReplacementNamed(context, '/appointment');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating appointment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule an Appointment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Date and Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              
              // Date selector
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Time selector
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _selectTime,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a time';
                  }
                  
                  // Parse the time to check if it's within clinic hours (8AM-5PM)
                  final parts = value.split(':');
                  if (parts.length == 2) {
                    final hour = int.tryParse(parts[0]);
                    if (hour != null) {
                      if (hour < 8 || hour >= 17) {
                        return 'Please select a time between 8:00 AM and 5:00 PM';
                      }
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              
              // Appointment type
              DropdownButtonFormField<String>(
                value: _selectedAppointmentType,
                decoration: const InputDecoration(
                  labelText: 'Appointment Type',
                  border: OutlineInputBorder(),
                ),
                items: _appointmentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an appointment type';
                  }
                  return null;
                },
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAppointmentType = newValue;
                  });
                },
              ),
              const SizedBox(height: 12),
              
              // Purpose
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Visit',
                  border: OutlineInputBorder(),
                  hintText: 'Please describe your reason for the appointment',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a purpose for your visit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Additional information section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 240, 240),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Important Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Please arrive 15 minutes before your scheduled appointment',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '• Bring a valid ID and medical records if available',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '• You will receive a confirmation once your appointment is approved',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}