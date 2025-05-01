import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> initializeSupabaseAuth() async {
    try {
      // Sign in anonymously to get a valid session
      final response = await supabase.auth.signInAnonymously();
      print('Supabase Auth Status: ${response.session?.accessToken}');

      // The session is automatically handled by the SDK
    } catch (e) {
      print('Auth initialization error: $e');
    }
  }
}
