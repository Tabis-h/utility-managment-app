import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utiliwise/src/home.dart';
import 'package:utiliwise/src/login.dart';
import 'package:utiliwise/src/worker_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/worker-dashboard': (context) => const WorkerDashboard(),
        '/home': (context) => const HomeView(userType: 'user'),
        '/login': (context) => const LoginScreen(),
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
    ));
  }}