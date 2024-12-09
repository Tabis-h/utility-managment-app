import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utiliwise/src/profile.dart';

import 'kyc.dart'; // Import ProfilePage or implement it

// Define the bottom navigation index provider
final bottomNavIndexProvider = StateProvider((ref) => 0);




class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dartbucket"),
        centerTitle: true, // Center the title for a more balanced appearance
      ),
      body: Consumer(
        builder: (context, ref, child) {
          // Watch the current navigation index state
          final currentIndex = ref.watch(bottomNavIndexProvider);
          return IndexedStack(
            index: currentIndex, // Show the selected screen
            children: const [
              HomeScreen(), // Custom widget for the Home tab
              SettingsScreen(), // Custom widget for the Settings tab
              ProfilePage(), // Profile tab
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          // Watch the navigation index to update the bottom navigation bar
          final currentIndex = ref.watch(bottomNavIndexProvider);
          return NavigationBar(
            selectedIndex: currentIndex,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
              NavigationDestination(icon: Icon(Icons.account_box), label: 'Profile'),
            ],
            onDestinationSelected: (value) {
              // Update the navigation index state when a tab is selected
              ref.read(bottomNavIndexProvider.notifier).update((state) => value);
            },
          );
        },
      ),
    );
  }
}

// Sample Home Screen Widget
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.home, size: 100, color: Colors.blue),
          Text(
            'Welcome to Home',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Sample Settings Screen Widget
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.settings, size: 100, color: Colors.green),
          Text(
            'Settings Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
class KYC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Verification"),
      ),
      body: const Center(
        child: Text(
          "KYC Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}





