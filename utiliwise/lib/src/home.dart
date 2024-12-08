import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utiliwise/src/login.dart';
import 'package:utiliwise/src/profile.dart';  // Import your login screen

final bottomNavIndexProvider = StateProvider((ref) => 0);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// AuthWrapper widget to check if user is logged in or not
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),  // Listen for auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());  // Show loading spinner while waiting for auth state
        }
        if (snapshot.hasData) {
          return const HomeView();  // Show HomeView if user is logged in
        } else {
          return const LoginScreen();  // Show LoginScreen if user is not logged in
        }
      },
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    print("Whole Page Built!");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dartbucket"),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          print('Index Stack Built!');
          final currentIndex = ref.watch(bottomNavIndexProvider);
          return IndexedStack(
            index: currentIndex,
            children: const [
              Center(
                child: Icon(
                  Icons.home,
                  size: 100,
                ),
              ),
              Center(
                child: Icon(
                  Icons.settings,
                  size: 100,
                ),
              ),
              const ProfilePage(),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final currentIndex = ref.watch(bottomNavIndexProvider);
          return NavigationBar(
            selectedIndex: currentIndex,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
              NavigationDestination(icon: Icon(Icons.account_box), label: 'Profile'),
            ],
            onDestinationSelected: (value) {
              ref.read(bottomNavIndexProvider.notifier).update((state) => value);
            },
          );
        },
      ),
    );
  }
}
