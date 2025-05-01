import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  static const String supabaseUrl = 'https://jbsyobxkcwemgmzwfbpw.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impic3lvYnhrY3dlbWdtendmYnB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM4OTg3NjMsImV4cCI6MjA0OTQ3NDc2M30.QXZSAw0El6p8Bk4fLbdFrGgSfZTo8ZIlNUxDMhXVOrg';

  static const FirebaseOptions firebaseOptions = FirebaseOptions(
      apiKey: "AIzaSyBuLwhQTqrUqveL9hyK97u0cap5xTYlNd4",
      authDomain: "utiliwise-9fe6f.firebaseapp.com",
      projectId: "utiliwise-9fe6f",
      messagingSenderId: "987511977342",
      appId: "1:987511977342:web:628d5339a148b6c92e6f2f"
    // Don't include storageBucket since you're using Supabase storage
  );
}