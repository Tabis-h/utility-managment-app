import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;
  final String bucketId = 'kyc-documents';

  Future<String> uploadKYCDocument(File documentImage, String firebaseUid, bool isDocument) async {
    final String fileName = isDocument ? 'document.jpg' : 'selfie.jpg';
    final String filePath = 'users/$firebaseUid/$fileName';

    await supabase.storage
        .from(bucketId)
        .uploadBinary(
      filePath,
      await documentImage.readAsBytes(),
      fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true
      ),
    );

    // Get a signed URL that expires in 1 hour
    return supabase.storage.from(bucketId).createSignedUrl(filePath, 3600);
  }
}
