import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _supabaseClient = Supabase.instance.client;
  bool _isLoading = true;
  Map<String, dynamic> _patientData = {};
  final Map<String, dynamic> _updatedData = {};
  final TextEditingController _birthdayController = TextEditingController();

  // Civil status options
  final List<String> _civilStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        final response = await _supabaseClient
            .from('patient')
            .select()
            .eq('patient_id', user.id)
            .single();
            
        if (response != null) {
          setState(() {
            _patientData = response;
            if (_patientData['birthday'] != null) {
              _birthdayController.text = _patientData['birthday'];
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user != null) {
        await _supabaseClient
            .from('patient')
            .update(_updatedData)
            .eq('patient_id', user.id);
            
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate profile was updated
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
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
        _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _updatedData['birthday'] = _birthdayController.text;
      });
    }
  }

  bool _isProfileComplete() {
    // Check all required fields
    final requiredFields = [
      'birthday',
      'place_of_birth',
      'house_number',
      'street',
      'barangay',
      'city',
      'province',
      'zip_code',
      'contact_number',
      'civil_status',
    ];

    for (var field in requiredFields) {
      if (_patientData[field] == null || _patientData[field].toString().isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Name section (read-only since it's filled during registration)
                    TextFormField(
                      initialValue: _patientData['first_name'] ?? '',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      initialValue: _patientData['middle_name'] ?? '',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      initialValue: _patientData['last_name'] ?? '',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      initialValue: _patientData['suffix'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Suffix',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['suffix'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Birthday field with date picker
                    TextFormField(
                      controller: _birthdayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Birthday',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDate,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your birthday';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Place of birth
                    TextFormField(
                      initialValue: _patientData['place_of_birth'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Place of Birth',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your place of birth';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['place_of_birth'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Civil status dropdown
                    DropdownButtonFormField<String>(
                      value: _patientData['civil_status'],
                      decoration: const InputDecoration(
                        labelText: 'Civil Status',
                        border: OutlineInputBorder(),
                      ),
                      items: _civilStatusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your civil status';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          _updatedData['civil_status'] = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact number
                    TextFormField(
                      initialValue: _patientData['contact_number'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your contact number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['contact_number'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email (read-only)
                    TextFormField(
                      initialValue: _patientData['email'] ?? '',
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Address Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // House number
                    TextFormField(
                      initialValue: _patientData['house_number'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'House Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your house number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['house_number'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Street
                    TextFormField(
                      initialValue: _patientData['street'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your street';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['street'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Barangay
                    TextFormField(
                      initialValue: _patientData['barangay'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Barangay',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your barangay';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['barangay'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // City
                    TextFormField(
                      initialValue: _patientData['city'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['city'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Province
                    TextFormField(
                      initialValue: _patientData['province'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Province',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your province';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['province'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Zip Code
                    TextFormField(
                      initialValue: _patientData['zip_code'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Zip Code',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your zip code';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value != null && value.isNotEmpty) {
                          _updatedData['zip_code'] = value;
                        }
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
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
                                'Save Profile',
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

// Function that can be called from other pages to check if the profile is complete
Future<bool> checkProfileCompletion(BuildContext context) async {
  final supabaseClient = Supabase.instance.client;
  final user = supabaseClient.auth.currentUser;
  
  if (user == null) {
    // User is not logged in, redirect to login
    Navigator.pushReplacementNamed(context, '/login');
    return false;
  }
  
  try {
    final response = await supabaseClient
        .from('patient')
        .select()
        .eq('patient_id', user.id)
        .single();
        
    if (response == null) {
      return false;
    }
    
    // Check all required fields
    final requiredFields = [
      'birthday',
      'place_of_birth',
      'house_number',
      'street',
      'barangay',
      'city',
      'province',
      'zip_code',
      'contact_number',
      'civil_status',
    ];

    for (var field in requiredFields) {
      if (response[field] == null || response[field].toString().isEmpty) {
        // Profile is incomplete, show dialog and navigate to profile page
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Complete Your Profile'),
              content: const Text(
                'Please complete your profile information before proceeding.',
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  child: const Text('Complete Profile', style: TextStyle(color: Colors.white)),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          },
        );
        return false;
      }
    }
    return true;
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error checking profile: $e')),
    );
    return false;
  }
}