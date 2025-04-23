import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  Future<void> initialize() async {
    await dotenv.load();

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    client = Supabase.instance.client;
  }

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    final AuthResponse res = await client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );

    if (res.user != null) {
      try {
        // Create data to insert
        final patientData = {
          'patient_id': res.user!.id,
          'email': email,
          'password': password,
          'first_name': userData['first_name'],
          'middle_name': userData['middle_name'] ?? null,
          'last_name': userData['last_name'],
          'username': userData['username'] ?? email.split('@')[0],
          'sex': userData['sex'],
        };

        print("Inserting patient data: $patientData");

        // Attempt insert with error handling
        final response = await client.from('patient').insert(patientData);
        print("Insert response: $response");
      } catch (e) {
        print("Error inserting patient data: $e");
      }
    }

    return res;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // Patient methods
  Future<Map<String, dynamic>?> getPatientProfile(String patientid) async {
    final response =
        await client
            .from('patient')
            .select()
            .eq('patient_id', patientid)
            .single();

    return response;
  }

  Future<void> updatePatientProfile(
    String patientid,
    Map<String, dynamic> data,
  ) async {
    await client.from('patient').update(data).eq('patient_id', patientid);
  }

  // Medical History methods
  Future<void> addMedicalHistory(Map<String, dynamic> data) async {
    await client.from('medical_history').insert(data);
  }

  Future<List<Map<String, dynamic>>> getMedicalHistory(String patientid) async {
    final response = await client
        .from('medical_History')
        .select()
        .eq('patient_id', patientid)
        .order('date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Appointment methods
  Future<void> createAppointment(Map<String, dynamic> data) async {
    await client.from('appointment').insert(data);
  }

  Future<List<Map<String, dynamic>>> getAppointments(String patientid) async {
    final response = await client
        .from('appointment')
        .select()
        .eq('patient_id', patientid)
        .order('appointment_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}
