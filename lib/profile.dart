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
    'Prefer not to say',
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
        final response =
            await _supabaseClient
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
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
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.red),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _updatedData['birthday'] = _birthdayController.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                )
                : SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context), // Pass context to header
                        _buildProfileImage(),
                        _buildPersonalInfoForm(),
                        _buildContactInfoForm(),
                        _buildAddressInfoForm(),
                        const SizedBox(height: 20),
                        _buildSaveButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Use Navigator.of(context)
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, color: Colors.red, size: 20),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IntimaCare',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color.fromARGB(255, 197, 0, 0),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/${_patientData['sex'] ?? 'female'}.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // First Name (read-only)
          _buildTextField(
            'First Name',
            initialValue: _patientData['first_name'] ?? '',
            readOnly: true,
          ),

          // Middle Name (read-only)
          _buildTextField(
            'Middle Name',
            initialValue: _patientData['middle_name'] ?? '',
            readOnly: true,
          ),

          // Last Name (read-only)
          _buildTextField(
            'Last Name',
            initialValue: _patientData['last_name'] ?? '',
            readOnly: true,
          ),

          // Suffix
          _buildTextField(
            'Suffix',
            initialValue: _patientData['suffix'] ?? '',
            onSaved: (value) {
              if (value != null && value.isNotEmpty) {
                _updatedData['suffix'] = value;
              }
            },
          ),

          // Sex (read-only)
          _buildTextField(
            'Sex',
            initialValue: _patientData['sex']?.toString().toUpperCase() ?? '',
            readOnly: true,
          ),

          // Birthday
          InkWell(
            onTap: _selectDate,
            child: IgnorePointer(
              child: _buildTextField(
                'Birthday',
                controller: _birthdayController,
                isDate: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your birthday';
                  }
                  return null;
                },
              ),
            ),
          ),

          // Place of Birth
          _buildTextField(
            'Place of Birth',
            initialValue: _patientData['place_of_birth'] ?? '',
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

          // Civil Status Dropdown
          _buildDropdownField(
            'Civil Status',
            value: _patientData['civil_status'],
            items: _civilStatusOptions,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your civil status';
              }
              return null;
            },
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _updatedData['civil_status'] = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Contact Number
          _buildTextField(
            'Contact Number',
            initialValue: _patientData['contact_number'] ?? '',
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

          // Email (read-only)
          _buildTextField(
            'Email',
            initialValue: _patientData['email'] ?? '',
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // House Number
          _buildTextField(
            'House Number',
            initialValue: _patientData['house_number'] ?? '',
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

          // Street
          _buildTextField(
            'Street',
            initialValue: _patientData['street'] ?? '',
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

          // Barangay
          _buildTextField(
            'Barangay',
            initialValue: _patientData['barangay'] ?? '',
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

          // City
          _buildTextField(
            'City',
            initialValue: _patientData['city'] ?? '',
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

          // Province
          _buildTextField(
            'Province',
            initialValue: _patientData['province'] ?? '',
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

          // Zip Code
          _buildTextField(
            'Zip Code',
            initialValue: _patientData['zip_code'] ?? '',
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
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, {
    String? initialValue,
    TextEditingController? controller,
    bool readOnly = false,
    bool isDate = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            initialValue: initialValue,
            readOnly: readOnly || isDate,
            keyboardType: keyboardType,
            validator: validator,
            onSaved: onSaved,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon:
                  isDate
                      ? const Icon(Icons.calendar_today, color: Colors.grey)
                      : null,
              errorStyle: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label, {
    String? value,
    required List<String> items,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              validator: validator,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                errorStyle: const TextStyle(color: Colors.red),
              ),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
              dropdownColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    final response =
        await supabaseClient
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
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Complete Profile',
                    style: TextStyle(color: Colors.white),
                  ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error checking profile: $e')));
    return false;
  }
}
