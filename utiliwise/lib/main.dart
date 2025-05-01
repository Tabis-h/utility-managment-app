import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:utiliwise/services/admin_service.dart';
import 'package:utiliwise/src/home_view.dart';
import 'package:utiliwise/src/login.dart';
import 'package:utiliwise/src/profile.dart';
import 'package:utiliwise/src/settings.dart';
import 'package:utiliwise/worker/worker_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'admin/admin_console.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBuLwhQTqrUqveL9hyK97u0cap5xTYlNd4",
          authDomain: "utiliwise-9fe6f.firebaseapp.com",
          projectId: "utiliwise-9fe6f",
          messagingSenderId: "987511977342",
          appId: "1:987511977342:web:628d5339a148b6c92e6f2f"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialize Supabase
  await supabase.Supabase.initialize(
    url: 'https://jbsyobxkcwemgmzwfbpw.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impic3lvYnhrY3dlbWdtendmYnB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM4OTg3NjMsImV4cCI6MjA0OTQ3NDc2M30.QXZSAw0El6p8Bk4fLbdFrGgSfZTo8ZIlNUxDMhXVOrg',
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/admin': (context) => FutureBuilder<bool>(
          future: AdminService.isAdmin(FirebaseAuth.instance.currentUser?.uid ?? ''),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data == true) {
              return AdminConsole();
            }
            return Center(child: Text('Access Denied'));
          },
        ),
        '/worker-dashboard': (context) => const WorkerDashboard(),
        '/home': (context) => const HomeView(userType: 'user'),
        '/login': (context) => const LoginScreen(),
      '/settings': (context) => const SettingsScreen(),
    '/profile': (context) => const ProfilePage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('workers')
                    .doc(snapshot.data!.uid)
                    .get(),
                builder: (context, workerSnapshot) {
                  if (workerSnapshot.connectionState == ConnectionState.done) {
                    if (workerSnapshot.data?.exists ?? false) {
                      return const WorkerDashboard();
                    }
                    return const HomeView(userType: 'user');
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
            return const LoginScreen();
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
