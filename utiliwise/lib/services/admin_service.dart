import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static Future<bool> isAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();
    return doc.exists;
  }
}
