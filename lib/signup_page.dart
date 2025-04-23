import 'package:flutter/material.dart';
import 'package:intimacare_client/services/supabase_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedSex;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _sexOptions = ['Male', 'Female'];

  Future<void> _signUp() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _selectedSex == null ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all required fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = {
        'first_name': _firstNameController.text.trim(),
        'middle_name': _middleNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'sex': _selectedSex,
        'username': _emailController.text.split('@')[0],
      };

      final response = await SupabaseService().signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userData: userData,
      );

      if (response.user != null) {
        if (mounted) {
          Navigator.pushNamed(context, '/confirmation');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign up failed: ${e.toString()}';
      });
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
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              // Fixed header
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Text(
                      'IntimaCare',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 197, 0, 0),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 20),
                              color: Colors.red.shade50,
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade800),
                              ),
                            ),
                          _buildTextField(
                            'First name',
                            'Enter first name',
                            controller: _firstNameController,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            'Middle name',
                            'Enter middle name',
                            controller: _middleNameController,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            'Last name',
                            'Enter last name',
                            controller: _lastNameController,
                          ),
                          const SizedBox(height: 15),
                          _buildSexDropdown(),
                          const SizedBox(height: 15),
                          _buildTextField(
                            'Email',
                            'Enter email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            'Password',
                            'Enter password',
                            controller: _passwordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
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
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              "Already have an account? Sign in",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
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

  Widget _buildTextField(
    String label,
    String hint, {
    TextEditingController? controller,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSexDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sex',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSex,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 15,
            ),
          ),
          hint: const Text('Select sex'),
          items:
              _sexOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedSex = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select your sex';
            }
            return null;
          },
        ),
      ],
    );
  }
}
