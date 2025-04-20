// prescription.dart
import 'package:flutter/material.dart';
import 'package:intimacare_client/appointment.dart';
import 'package:intimacare_client/home.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  // Sample prescription data - in a real app, this would come from an API or database
  final List<Prescription> prescriptions = [
    Prescription(
      id: '1',
      date: DateTime(2025, 2, 28),
      expiryDate: DateTime(2025, 3, 25),
      diagnosis: 'Syphilis',
      medications: [
        Medication(
          name: 'Benzathine Penicillin',
          dosage: '100mg',
          instruction: '3 times a day',
        ),
        Medication(
          name: 'Doxycycline',
          dosage: '100mg',
          instruction: 'Everynight',
        ),
      ],
    ),
    Prescription(
      id: '2',
      date: DateTime(2024, 11, 14),
      expiryDate: DateTime(2024, 11, 30),
      diagnosis: 'Chlamydia',
      medications: [
        Medication(
          name: 'Azithromycin',
          dosage: '1g',
          instruction: 'Single dose',
        ),
      ],
    ),
  ];

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
                  const ProfileIconWithDropdown(),
                ],
              ),
            ),

            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prescriptions',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'View your current and past prescriptions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: prescriptions.length,
                      itemBuilder: (context, index) {
                        return PrescriptionCard(
                          prescription: prescriptions[index],
                          onTap: () {
                            _showPrescriptionDetails(
                              context,
                              prescriptions[index],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom navigation
            Container(
              height: 60,
              color: Colors.white, // Changed from red to white
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    Icons.calendar_today,
                    'Appointment',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppointmentPage(),
                        ),
                      );
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
                    isSelected: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrescriptionDetails(
    BuildContext context,
    Prescription prescription,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getFormattedDate(prescription.date)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Diagnosed with ${prescription.diagnosis}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Valid until: ${_getFormattedDate(prescription.expiryDate)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              const Text(
                'Medications:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...prescription.medications
                  .map((med) => _buildMedicationItem(med))
                  .toList(),
              const SizedBox(height: 20),
              const Text(
                'Instructions:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                '• Take medications as prescribed\n'
                '• Complete the full course even if you feel better\n'
                '• Contact the clinic if you experience severe side effects',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationItem(Medication medication) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medication.name} (${medication.dosage})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${medication.instruction}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback onTap;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if prescription is expired
    final bool isExpired = prescription.expiryDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getFormattedDate(prescription.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Expired',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Text(
                  'Valid until: ${_getFormattedDate(prescription.expiryDate)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class Prescription {
  final String id;
  final DateTime date;
  final DateTime expiryDate;
  final String diagnosis;
  final List<Medication> medications;

  Prescription({
    required this.id,
    required this.date,
    required this.expiryDate,
    required this.diagnosis,
    required this.medications,
  });
}

class Medication {
  final String name;
  final String dosage;
  final String instruction;

  Medication({
    required this.name,
    required this.dosage,
    required this.instruction,
  });
}

class ProfileIconWithDropdown extends StatelessWidget {
  const ProfileIconWithDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 'logout') {
          // Handle logout
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else if (value == 'profile') {
          // Navigate to profile page
          Navigator.pushNamed(context, '/profile');
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('View Profile'),
            ),
            const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
          ],
      icon: const CircleAvatar(
        backgroundColor: Color.fromARGB(255, 245, 245, 245),
        child: Icon(Icons.menu, color: Color.fromARGB(255, 0, 0, 0)),
      ),
    );
  }
}
