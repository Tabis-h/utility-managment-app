import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utiliwise/src/profile.dart';

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

// Home Screen to display the list of workers from Firebase Firestore
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('workers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final workers = snapshot.data!.docs;

        // Shuffle the list of workers to display them randomly
        workers.shuffle();

        return ListView.builder(
          itemCount: workers.length,
          itemBuilder: (context, index) {
            final worker = workers[index];

            // Get worker data
            final name = worker['name'];
            final workPrice = worker['workPrice'];

            return WorkerCard(
              name: name,
              workPrice: workPrice,
            );
          },
        );
      },
    );
  }
}

// Widget to display a worker's information
class WorkerCard extends StatelessWidget {
  final String name;
  final String workPrice;

  const WorkerCard({
    required this.name,
    required this.workPrice,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
          radius: 30,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Work Price: \$' + workPrice),
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
