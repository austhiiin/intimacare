// appointment.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intimacare_client/prescription_page.dart';
import 'package:intimacare_client/home.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final List<String> patientTypes = [
    'New Patient',
    'Regular Check-up',
    'Follow-up',
  ];
  final List<String> appointmentPurposes = [
    'Consultation',
    'STI/STD Testing',
    'Treatment',
    'Counseling',
    'Other',
  ];

  String? selectedPatientType;
  String? selectedPurpose;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  String notesText = '';

  // Controller for notes text field
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Top section with profile icon and IntimaCare title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'IntimaCare',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800, // ExtraBold variant
                        color: Color.fromARGB(255, 197, 0, 0), // Red color
                      ),
                    ),
                  ),
                  // Profile icon
                  const ProfileIconWithDropdown(),
                ],
              ),
            ),

            // Content section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Appointment',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Patient Type
                    _buildLabelText('Type of Patient'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedPatientType,
                      items: patientTypes,
                      hint: 'Select type of Patient',
                      onChanged: (value) {
                        setState(() {
                          selectedPatientType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Purpose
                    _buildLabelText('Purpose'),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: selectedPurpose,
                      items: appointmentPurposes,
                      hint: 'Select purpose of appointment',
                      onChanged: (value) {
                        setState(() {
                          selectedPurpose = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date picker
                    _buildLabelText('Date'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Select date'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(
                                color:
                                    selectedDate == null
                                        ? Colors.grey[600]
                                        : Colors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_today, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Time picker
                    _buildLabelText('Time'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTime == null
                                  ? 'Select time'
                                  : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period.name}',
                              style: TextStyle(
                                color:
                                    selectedTime == null
                                        ? Colors.grey[600]
                                        : Colors.black,
                              ),
                            ),
                            const Icon(Icons.access_time, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Notes
                    _buildLabelText('Notes (Optional)'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add any additional information',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(15),
                        ),
                        onChanged: (value) {
                          notesText = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit button
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child:
                              isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
              height: 60,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    Icons.calendar_today,
                    'Appointment',
                    isSelected: true,
                    onTap: () {
                      // No navigation needed as we're already on this page
                    },
                  ),
                  _buildNavItem(
                    Icons.home,
                    'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(
                    Icons.description,
                    'Prescription',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrescriptionPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save appointment to database with improved error handling
  Future<void> _saveAppointment() async {
    // Validate all required fields
    if (selectedPatientType == null ||
        selectedPurpose == null ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a datetime object that combines date and time
      final DateTime appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      // Debug prints to help troubleshoot
      print('Attempting to save appointment with data:');
      print('Patient_ID: ${user.id}');
      print('Appointment_Date: ${appointmentDateTime.toIso8601String()}');
      print('Type_of_Patient: $selectedPatientType');
      print('Purpose: $selectedPurpose');
      print('Notes: ${notesText.isNotEmpty ? notesText : "null"}');

      // Insert appointment into database
      final response = await Supabase.instance.client
          .from(
            'appointment',
          ) // Make sure table name matches your database exactly
          .insert({
            'patient_id': user.id,
            'appointment_date': appointmentDateTime.toIso8601String(),
            'type_of_patient': selectedPatientType,
            'purpose': selectedPurpose,
            'notes': notesText.isNotEmpty ? notesText : null,
          });

      print('Appointment saved successfully!');
      print('Response data: $response');

      // Show success dialog
      if (mounted) {
        _showAppointmentConfirmationDialog(context);
      }
    } catch (e) {
      print('Error saving appointment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: Container(),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Restrict to workdays (Monday - Friday)
    bool isWeekend(DateTime date) {
      return date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
    }

    // Get current date
    final DateTime now = DateTime.now();
    // Define first available date (next day if after 5PM)
    DateTime firstAvailableDate =
        now.hour >= 17 ? now.add(const Duration(days: 1)) : now;

    // Skip to Monday if it's a weekend
    if (isWeekend(firstAvailableDate)) {
      // If it's Saturday, add 2 days to get to Monday
      // If it's Sunday, add 1 day to get to Monday
      firstAvailableDate = firstAvailableDate.add(
        Duration(days: firstAvailableDate.weekday == DateTime.saturday ? 2 : 1),
      );
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstAvailableDate,
      firstDate: firstAvailableDate,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      selectableDayPredicate: (DateTime date) {
        // Allow only workdays (Monday to Friday)
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTime = null; // Reset time when date changes
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    final TimeOfDay now = TimeOfDay.now();
    // Define clinic hours
    const TimeOfDay clinicOpens = TimeOfDay(hour: 8, minute: 0);
    const TimeOfDay clinicCloses = TimeOfDay(hour: 17, minute: 0);

    // Check if selected date is today
    final bool isToday =
        selectedDate!.day == DateTime.now().day &&
        selectedDate!.month == DateTime.now().month &&
        selectedDate!.year == DateTime.now().year;

    // Define initial time and time constraints
    TimeOfDay initialTime;
    bool Function(TimeOfDay)? timeConstraint;

    if (isToday) {
      // If today, start from next available hour
      initialTime =
          now.hour < clinicOpens.hour
              ? clinicOpens
              : TimeOfDay(hour: now.hour + 1, minute: 0);

      // For today, restrict times to clinic hours and future times
      timeConstraint = (TimeOfDay time) {
        return _timeToDouble(time) >= _timeToDouble(initialTime) &&
            _timeToDouble(time) < _timeToDouble(clinicCloses);
      };
    } else {
      // For future dates, start from clinic opening time
      initialTime = clinicOpens;

      // For future dates, restrict only to clinic hours
      timeConstraint = (TimeOfDay time) {
        return _timeToDouble(time) >= _timeToDouble(clinicOpens) &&
            _timeToDouble(time) < _timeToDouble(clinicCloses);
      };
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.red),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Validate if time is within constraints
      if (timeConstraint(picked)) {
        setState(() {
          selectedTime = picked;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a time within clinic hours (8:00 AM - 5:00 PM)',
            ),
          ),
        );
      }
    }
  }

  // Helper to convert TimeOfDay to double for comparison
  double _timeToDouble(TimeOfDay time) => time.hour + time.minute / 60.0;

  void _showAppointmentConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your appointment has been successfully scheduled.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Text('Type: $selectedPatientType'),
              Text('Purpose: $selectedPurpose'),
              Text(
                'Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
              Text('Time: ${selectedTime!.format(context)}'),
              if (notesText.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Notes: $notesText'),
              ],
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset form
                setState(() {
                  selectedPatientType = null;
                  selectedPurpose = null;
                  selectedDate = null;
                  selectedTime = null;
                  notesController.clear();
                  notesText = '';
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          onEnter: (_) {},
          onExit: (_) {},
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
            builder: (context, scale, child) {
              return AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: Colors.red, // Red color for the icons
                      size: isSelected ? 30 : 24, // Bigger icon when selected
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.red, // Red color for the label
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProfileIconWithDropdown extends StatelessWidget {
  const ProfileIconWithDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Logout'),
                ],
              ),
            ),
          ],
      onSelected: (String value) async {
        if (value == 'profile') {
          // Navigate to profile page
          Navigator.pushNamed(context, '/profile');
        } else if (value == 'logout') {
          // Show logout confirmation dialog
          await _showLogoutConfirmationDialog(context);
        }
      },
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 245, 245, 245),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.menu, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    );
                  },
                );

                try {
                  // Sign out from Supabase
                  await Supabase.instance.client.auth.signOut();

                  // Dismiss loading dialog
                  Navigator.of(context).pop();

                  // Navigate to login page
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false, // Remove all routes from stack
                  );
                } catch (e) {
                  // Dismiss loading dialog
                  Navigator.of(context).pop();

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}
