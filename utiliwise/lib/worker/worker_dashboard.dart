import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utiliwise/worker/worker_notifications.dart';

import 'kyc.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class WorkerDashboard extends ConsumerStatefulWidget {
  const WorkerDashboard({super.key});

  @override
  ConsumerState<WorkerDashboard> createState() => _WorkerDashboardState();

}

class _WorkerDashboardState extends ConsumerState<WorkerDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  bool _isAvailable = true;
  String _selectedWorkType = 'Plumber';
  final List<String> _workTypes = ['Plumber', 'Electrician', 'Mechanic'];
  Stream<DocumentSnapshot> get workerStream => FirebaseFirestore.instance
      .collection('workers')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  Future<void> _loadWorkerData() async {
    final workerId = FirebaseAuth.instance.currentUser?.uid;
    if (workerId != null) {
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .get();

      if (workerDoc.exists) {
        final data = workerDoc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _mobileController.text = data['mobile'] ?? '';
          _priceController.text = data['workPrice'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _experienceController.text = data['experience'] ?? '';
          _isAvailable = data['isAvailable'] ?? true;
          _selectedWorkType = data['workType'] ?? 'Plumber';
        });
      }
    }
  }

  Future<void> _updateWorkerProfile() async {
    final workerId = FirebaseAuth.instance.currentUser?.uid;
    if (workerId != null) {
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(workerId)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
        'mobile': _mobileController.text,
        'workPrice': _priceController.text,
        'description': _descriptionController.text,
        'experience': _experienceController.text,
        'isAvailable': _isAvailable,
        'workType': _selectedWorkType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Dashboard'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('workerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              int unreadNotifications = snapshot.hasData ? snapshot.data!.docs.length : 0;

              return Badge(
                isLabelVisible: unreadNotifications > 0,
                label: Text('$unreadNotifications'),
                child: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WorkerNotificationsScreen()),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _mobileController,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Professional Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedWorkType,
                          decoration: const InputDecoration(
                            labelText: 'Work Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.work),
                          ),
                          items: _workTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWorkType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Work Price (per hour)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _experienceController,
                          decoration: const InputDecoration(
                            labelText: 'Years of Experience',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timeline),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Work Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<DocumentSnapshot>(
                          stream: workerStream,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            final workerData = snapshot.data!.data() as Map<String, dynamic>;
                            final kycStatus = workerData['kyc']?['status'];
                            final isVerified = kycStatus == 'verified';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SwitchListTile(
                                  title: const Text('Available for Work'),
                                  subtitle: Text(isVerified
                                      ? (_isAvailable ? 'Active' : 'Inactive')
                                      : 'Complete KYC verification first'),
                                  value: isVerified && _isAvailable,
                                  onChanged: isVerified
                                      ? (value) {
                                    setState(() {
                                      _isAvailable = value;
                                    });
                                  }
                                      : null,
                                ),
                                if (!isVerified)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'KYC verification is required to enable work availability',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _updateWorkerProfile,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const KYCScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.verified_user_outlined),
            selectedIcon: Icon(Icons.verified_user),
            label: 'Verification',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}
