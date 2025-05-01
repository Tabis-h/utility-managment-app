import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utiliwise/src/profile.dart';
import 'package:utiliwise/src/settings.dart';
import 'package:utiliwise/worker/worker_dashboard.dart';
import 'package:utiliwise/src/user_home_screen.dart';
import 'package:utiliwise/src/user_booking_requests_screen.dart';
import '../services/admin_service.dart';

final bottomNavIndexProvider = StateProvider((ref) => 0);

class HomeView extends StatelessWidget {
  final String userType;
  const HomeView({
    super.key,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Utiliwise",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.black54),
            onPressed: () async {
              final isAdmin = await AdminService.isAdmin(
                  FirebaseAuth.instance.currentUser!.uid);
              if (isAdmin) {
                Navigator.pushNamed(context, '/admin');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Access Denied')),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final currentIndex = ref.watch(bottomNavIndexProvider);
          return IndexedStack(
            index: currentIndex,
            children: [
              userType == 'worker'
                  ? const WorkerDashboard()
                  : const UserHomeScreen(),
              const UserBookingRequestsScreen(),
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
            elevation: 8,
            backgroundColor: Colors.white,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'Bookings',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onDestinationSelected: (value) {
              ref.read(bottomNavIndexProvider.notifier).state = value;
            },
          );
        },
      ),
    );
  }
}