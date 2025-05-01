import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utiliwise/worker/worker_notifications.dart';
import 'package:utiliwise/worker/worker_booking_requests.dart';
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
  final TextEditingController _upiIdController = TextEditingController(); // UPI ID Controller
  bool _isAvailable = true;
  String _selectedWorkType = 'Plumber';
  final List<String> _workTypes = ['Plumber', 'Electrician', 'Mechanic', 'Gardener'];
  bool _isUpdating = false;


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
          _upiIdController.text = data['upiId'] ?? ''; // Load UPI ID
        });
      }
    }
  }

  Future<void> _updateWorkerProfile() async {
    setState(() => _isUpdating = true);
    final workerId = FirebaseAuth.instance.currentUser?.uid;
    if (workerId != null) {
      try {
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
          'upiId': _upiIdController.text, // Save UPI ID
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isUpdating = false);
      }
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
                  icon: const Icon(Icons.notifications),
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
                _buildSection(
                  title: 'Personal Information',
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _upiIdController,
                      label: 'UPI ID',
                      icon: Icons.payment,
                      prefixText: 'UPI: ', // Optional: Add a prefix
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Professional Information',
                  children: [
                    _buildDropdown(
                      value: _selectedWorkType,
                      label: 'Work Type',
                      icon: Icons.work,
                      items: _workTypes,
                      onChanged: (value) => setState(() => _selectedWorkType = value!),
                    ),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Work Price (per hour)',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Years of Experience',
                      icon: Icons.timeline,
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Work Description',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildUpdateButton(),
              ],
            ),
          ),
          const KYCScreen(),
          const WorkerBookingRequests(),
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
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
          prefixText: prefixText,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        items: items.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateWorkerProfile,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isUpdating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Update Profile',
          style: TextStyle(fontSize: 16),
        ),
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
    _upiIdController.dispose(); // Dispose UPI ID controller
    super.dispose();
  }
}
