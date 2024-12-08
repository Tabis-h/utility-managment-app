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
  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Fetch user data from Firestore
  Future<Map<String, String>> getUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user profile data from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        // Safely check for field existence before accessing them
        var data = doc.data() as Map<String, dynamic>?;

        return {
          'name': data != null && data.containsKey('name') ? data['name'] : 'No name available',
          'email': data != null && data.containsKey('email') ? data['email'] : 'No email available',
          'mobile': data != null && data.containsKey('mobile') ? data['mobile'] : 'No mobile available',
          'address': data != null && data.containsKey('address') ? data['address'] : 'No address available',
          'photoUrl': data != null && data.containsKey('photoUrl') ? data['photoUrl'] : '',  // Add photoUrl field
        };
      } else {
        return {
          'name': 'No name available',
          'email': 'No email available',
          'mobile': 'No mobile available',
          'address': 'No address available',
          'photoUrl': '',  // Add empty photoUrl
        };
      }
    }

    return {
      'name': 'No name available',
      'email': 'No email available',
      'mobile': 'No mobile available',
      'address': 'No address available',
      'photoUrl': '',  // Add empty photoUrl
    };
  }

  // Update user profile data in Firestore
  Future<void> updateProfile(String mobile, String address) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'mobile': mobile,
        'address': address,
      });

      // Update state to stop editing
      setState(() {
        _isEditing = false;
      });
    }
  }

  // Pick profile image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Upload the selected image to Firebase Storage
      await _uploadProfileImage();
    }
  }

  // Upload profile image to Firebase Storage
  Future<void> _uploadProfileImage() async {
    if (_profileImage != null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          String fileName = 'profile_images/${user.uid}.jpg';
          Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
          UploadTask uploadTask = storageRef.putFile(_profileImage!);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          // Update Firestore with the profile image URL
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'photoUrl': downloadUrl,
          });

          setState(() {
            // Update profile image URL
            user.updateProfile(photoURL: downloadUrl);
          });
        } catch (e) {
          print('Error uploading image: $e');
        }
      }
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
                    // Profile Picture Section
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Display user information
                    Text(
                      'Name: ${userProfile['name']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Email: ${userProfile['email']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),

                    // Mobile and Address fields
                    _isEditing
                        ? Column(
                      children: [
                        TextField(
                          controller: _mobileController..text = userProfile['mobile']!,
                          decoration: const InputDecoration(labelText: 'Mobile Number'),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10), // Max length for mobile number
                          ],
                        ),
                        TextField(
                          controller: _addressController..text = userProfile['address']!,
                          decoration: const InputDecoration(labelText: 'Address'),
                          maxLength: 50, // Max length for address
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            updateProfile(
                              _mobileController.text,
                              _addressController.text,
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

                    // Logout button
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
