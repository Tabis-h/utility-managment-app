import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String userType; // 'user' or 'worker'
  const ProfilePage({super.key, required this.userType});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  bool _isLoading = true;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;

  // Worker-specific controllers
  late TextEditingController _workPriceController;
  String? _selectedWorkType;
  final List<String> _workTypes = ['Plumber', 'Electrician', 'Mechanic'];

  // User-specific controller
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();

    if (widget.userType == 'worker') {
      _workPriceController = TextEditingController();
    } else {
      _addressController = TextEditingController();
    }

    _loadProfileData();
  }

  void _loadProfileData() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(widget.userType == 'worker' ? 'workers' : 'users')
          .doc(_user.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _mobileController.text = data['mobile'] ?? '';

        if (widget.userType == 'worker') {
          _workPriceController.text = data['workPrice'] ?? '';
          _selectedWorkType = data['workType'];
        } else {
          _addressController.text = data['address'] ?? '';
        }
      }
    } catch (e) {
      print('Error loading profile data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> profileData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'mobile': _mobileController.text,
      };

      if (widget.userType == 'worker') {
        profileData.addAll({
          'workPrice': _workPriceController.text,
          'workType': _selectedWorkType,
        });
      } else {
        profileData['address'] = _addressController.text;
      }

      await FirebaseFirestore.instance
          .collection(widget.userType == 'worker' ? 'workers' : 'users')
          .doc(_user.uid)
          .set(profileData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: _isEditing, // Enable editing based on your state variable
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[100],
        ),
      ),
    );
  }

// [Previous imports and class declarations remain the same]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          '${widget.userType == 'worker' ? 'Worker' : 'User'} Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: const AssetImage('assets/images/as.png'),
                          child: Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // Add image picker functionality
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              if (_isEditing) {
                                _saveProfileData();
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                            child: Text(
                              _isEditing ? 'Save' : 'Edit',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 20),
                      // Existing TextField widgets
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
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
                      // Worker/User specific fields
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

}