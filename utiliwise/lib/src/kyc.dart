import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class KYCPage extends StatefulWidget {
  @override
  _KYCPageState createState() => _KYCPageState();
}

class _KYCPageState extends State<KYCPage> {
  File? aadhaarFile;
  File? selfieFile;
  bool isLoading = false;

  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> pickImage(ImageSource source, bool isAadhaar) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (isAadhaar) {
          aadhaarFile = File(pickedFile.path);
        } else {
          selfieFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> uploadKYCData() async {
    if (aadhaarFile == null || selfieFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload both Aadhaar card and Selfie')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Upload Aadhaar card
      String aadhaarUrl = await _uploadFileToFirebase(aadhaarFile!, 'aadhaar');

      // Upload Selfie
      String selfieUrl = await _uploadFileToFirebase(selfieFile!, 'selfie');

      // Save URLs to Firestore
      await firestore.collection('kyc').add({
        'aadhaar_url': aadhaarUrl,
        'selfie_url': selfieUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('KYC submitted successfully!')),
      );
      setState(() {
        aadhaarFile = null;
        selfieFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading KYC: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> _uploadFileToFirebase(File file, String type) async {
    final String fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = storage.ref().child('kyc/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KYC Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Upload Aadhaar Card', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            aadhaarFile == null
                ? OutlinedButton(
              onPressed: () => pickImage(ImageSource.gallery, true),
              child: Text('Choose Aadhaar Card'),
            )
                : Image.file(aadhaarFile!, height: 150),

            SizedBox(height: 16),
            Text('Take a Selfie', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            selfieFile == null
                ? OutlinedButton(
              onPressed: () => pickImage(ImageSource.camera, false),
              child: Text('Take Selfie'),
            )
                : Image.file(selfieFile!, height: 150),

            SizedBox(height: 32),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: uploadKYCData,
              child: Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }
}



