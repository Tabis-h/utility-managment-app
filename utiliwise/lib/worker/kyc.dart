import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';


import '../main.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class KYCScreen extends StatefulWidget {
  const KYCScreen({Key? key}) : super(key: key);

  @override
  State<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {

  final storageService = StorageService();
  final authService = AuthService();


  @override
  void initState() {
    super.initState();
    _initializeAuth();  // Add this line
  }

  Future<void> _initializeAuth() async {
    await authService.initializeSupabaseAuth();
  }


  String? selectedDocType;
  File? documentImage;
  File? selfieImage;
  bool isLoading = false;

  final List<String> documentTypes = [
    'Aadhar Card',
    'PAN Card',
    'Voter ID',
    'Passport'
  ];

  final supabase = Supabase.instance.client;
  final bucketId = 'kyc-documents'; // Use this exact name in Supabase dashboard

  Future<void> uploadKYC() async {
    print('Session: ${supabase.auth.currentSession}');
    print('Firebase UID: ${FirebaseAuth.instance.currentUser?.uid}');

    // Check if Firebase user exists first
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login with Firebase first')),
      );
      return;
    }
    if (selectedDocType == null || documentImage == null || selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Using the storage service to upload files
      final documentUrl = await storageService.uploadKYCDocument(documentImage!, uid, true);
      final selfieUrl = await storageService.uploadKYCDocument(selfieImage!, uid, false);

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(uid)
          .update({
        'kyc': {
          'documentType': selectedDocType,
          'documentUrl': documentUrl,
          'selfieUrl': selfieUrl,
          'status': 'pending',
          'submittedAt': FieldValue.serverTimestamp(),
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC submitted successfully')),
      );
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting KYC')),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> pickImage(bool isDocument) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        if (isDocument) {
          documentImage = File(image.path);
        } else {
          selfieImage = File(image.path);
        }
      });
    }
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
      url: 'https://jbsyobxkcwemgmzwfbpw.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impic3lvYnhrY3dlbWdtendmYnB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM4OTg3NjMsImV4cCI6MjA0OTQ3NDc2M30.QXZSAw0El6p8Bk4fLbdFrGgSfZTo8ZIlNUxDMhXVOrg',
    );

    runApp(const MyApp());
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final kycData = snapshot.data?.get('kyc');
          final kycStatus = kycData?['status'] ?? 'not_submitted';

          if (kycStatus == 'verified') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('KYC Verified',
                      style: TextStyle(fontSize: 24, color: Colors.green)),
                  SizedBox(height: 8),
                  Text('Verified on: ${_formatTimestamp(kycData['verifiedAt'])}'),
                ],
              ),
            );
          } else if (kycStatus == 'pending') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('KYC Verification Pending',
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  Text('Submitted on: ${_formatTimestamp(kycData['submittedAt'])}'),
                ],
              ),
            );
          } else if (kycStatus == 'rejected') {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      color: Colors.red[100],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 48),
                            SizedBox(height: 8),
                            Text('KYC Rejected',
                                style: TextStyle(fontSize: 20, color: Colors.red)),
                            SizedBox(height: 16),
                            Text('Please submit your documents again'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildKYCForm(),
                ],
              ),
            );
          }

          return _buildKYCForm();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildKYCForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Document Verification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDocType,
                    decoration: const InputDecoration(
                      labelText: 'Select Document Type',
                      border: OutlineInputBorder(),
                    ),
                    items: documentTypes.map((String type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() => selectedDocType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImagePicker(
                          'Upload Document',
                          documentImage,
                              () => pickImage(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImagePicker(
                          'Take Selfie',
                          selfieImage,
                              () => pickImage(false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: isLoading ? null : uploadKYC,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit KYC'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String title, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: onTap,
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 32, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text('Tap to capture', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    );
  }


  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('MMM dd, yyyy hh:mm a').format(timestamp.toDate());
  }


}
