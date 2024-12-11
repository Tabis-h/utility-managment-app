import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static const String _serverKey = 'YOUR_FIREBASE_SERVER_KEY';

  static Future<void> sendPushNotification(String workerId, String message) async {
    final workerToken = await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .get()
        .then((doc) => doc.data()?['fcmToken']);

    if (workerToken != null) {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'notification': {
            'title': 'New Booking Request',
            'body': message,
          },
          'to': workerToken,
        }),
      );
    }
  }
}
