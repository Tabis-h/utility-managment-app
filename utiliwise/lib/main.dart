import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utiliwise/src/home.dart';
import 'package:utiliwise/src/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Utility App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginScreen(); // Navigate to login if not logged in
    } else {
      return const HomeView(); // Navigate to home if logged in
    }
  }
}
