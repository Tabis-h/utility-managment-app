import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utiliwise/src/profile.dart';
import 'package:utiliwise/src/settings.dart';
import 'package:utiliwise/worker/worker_dashboard.dart';
import 'package:utiliwise/worker/worker_details.dart';

import '../services/admin_service.dart';

// Define the bottom navigation index provider
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
              const SettingsScreen(),
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
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
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



class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('workers')
                .where('isAvailable', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              final workers = snapshot.data!.docs;

              if (workers.isEmpty) {
                return const Center(
                  child: Text(
                    'No workers available at the moment',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              workers.shuffle();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return WorkerCard(
                    workerId: workers[index].id,
                    name: worker['name'],
                    workPrice: worker['workPrice'],
                    workType: worker['workType'],
                  );
                },
              );
            },
          ),
        )      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search workers...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All'),
          _buildFilterChip('Plumber'),
          _buildFilterChip('Electrician'),
          _buildFilterChip('Mechanic'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool selected) {
          // Handle filter selection
        },
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final String name;
  final String workPrice;
  final String workType;
  final String workerId;  // Add this field

  const WorkerCard({
    required this.name,
    required this.workPrice,
    required this.workType,
    required this.workerId,  // Add this parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerDetailsScreen(
                workerId: workerId,
                name: name,
                workType: workType,
                workPrice: workPrice,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.work, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          workType,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                        Text(
                          workPrice,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const Text(' 4.8 (124 reviews)'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

