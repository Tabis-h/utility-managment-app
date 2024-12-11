import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  static final supabase = Supabase.instance.client;

  static Future<String> uploadImage(File imageFile, String uid) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'kyc/$uid/$fileName';

      await supabase.storage
          .from('kyc-documents')
          .uploadBinary(filePath, bytes);

      final imageUrl = supabase.storage
          .from('kyc-documents')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw 'Upload failed: $e';
    }
  }
}