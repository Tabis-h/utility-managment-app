import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  String _userType = 'user'; // Default user type
  final List<String> _workTypes = ['Plumber', 'Electrician', 'Mechanical', 'Labour'];

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _workTypeController.dispose();
    super.dispose();
  }

  // Fetch user data from Firestore
  Future<Map<String, String>> getUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>?;

        _userType = data != null && data.containsKey('userType') ? data['userType'] : 'user';

        return {
          'name': data != null && data.containsKey('name') ? data['name'] : 'No name available',
          'email': data != null && data.containsKey('email') ? data['email'] : 'No email available',
          'mobile': data != null && data.containsKey('mobile') ? data['mobile'] : 'No mobile available',
          'address': data != null && data.containsKey('address') ? data['address'] : 'No address available',
          'photoUrl': data != null && data.containsKey('photoUrl') ? data['photoUrl'] : '',
          'price': data != null && data.containsKey('price') ? data['price'] : '',
          'workType': data != null && data.containsKey('workType') ? data['workType'] : '',
        };
      }
    }

    return {
      'name': 'No name available',
      'email': 'No email available',
      'mobile': 'No mobile available',
      'address': 'No address available',
      'photoUrl': '',
      'price': '',
      'workType': '',
    };
  }

  // Update user profile data in Firestore
  Future<void> updateProfile(String mobile, String address, String price, String workType) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'mobile': mobile,
        'address': address,
        if (_userType == 'worker') ...{
          'price': price,
          'workType': workType,
        },
      });

      setState(() {
        _isEditing = false;
      });
    }
  }

  // Logout user
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No profile data found.'));
        }

        var userProfile = snapshot.data!;
        String photoUrl = userProfile['photoUrl'] ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {}, // Add functionality to update profile picture if needed
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Name: ${userProfile['name']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Email: ${userProfile['email']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),

                    _isEditing
                        ? Column(
                            children: [
                              TextField(
                                controller: _mobileController..text = userProfile['mobile']!,
                                decoration: const InputDecoration(labelText: 'Mobile Number'),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                ],
                              ),
                              TextField(
                                controller: _addressController..text = userProfile['address']!,
                                decoration: const InputDecoration(labelText: 'Address'),
                                maxLength: 50,
                              ),
                              if (_userType == 'worker') ...[
                                TextField(
                                  controller: _priceController..text = userProfile['price']!,
                                  decoration: const InputDecoration(labelText: 'Work Price'),
                                  keyboardType: TextInputType.number,
                                ),
                                DropdownButtonFormField<String>(
                                  value: _workTypeController.text.isEmpty
                                      ? userProfile['workType']!
                                      : _workTypeController.text,
                                  decoration: const InputDecoration(labelText: 'Work Type'),
                                  items: _workTypes.map((String workType) {
                                    return DropdownMenuItem<String>(
                                      value: workType,
                                      child: Text(workType),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      _workTypeController.text = value;
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  updateProfile(
                                    _mobileController.text,
                                    _addressController.text,
                                    _priceController.text,
                                    _workTypeController.text,
                                  );
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                'Mobile: ${userProfile['mobile']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Address: ${userProfile['address']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              if (_userType == 'worker') ...[
                                Text(
                                  'Price: ${userProfile['price']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Work Type: ${userProfile['workType']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = true;
                                  });
                                },
                                child: const Text('Edit Profile'),
                              ),
                            ],
                          ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

