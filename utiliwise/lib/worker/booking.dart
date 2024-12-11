import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class BookingScreen extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workPrice;

  const BookingScreen({
    required this.workerId,
    required this.workerName,
    required this.workPrice,
    Key? key,
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> createBooking() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final bookingId = FirebaseFirestore.instance.collection('bookings').doc().id;

    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set({
      'bookingId': bookingId,
      'userId': userId,
      'workerId': widget.workerId,
      'workerName': widget.workerName,
      'status': 'pending',
      'date': selectedDate,
      'time': selectedTime?.format(context),
      'address': addressController.text,
      'description': descriptionController.text,
      'price': widget.workPrice,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Send notification to worker
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId)
        .collection('notifications')
        .add({
      'type': 'new_booking',
      'bookingId': bookingId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text('Select Date'),
                subtitle: Text(selectedDate?.toString() ?? 'Not selected'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Select Time'),
                subtitle: Text(selectedTime?.format(context) ?? 'Not selected'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Service Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Problem Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await createBooking();
                  await NotificationService.sendPushNotification(
                      widget.workerId,
                      'New booking request from ${FirebaseAuth.instance.currentUser?.displayName}'
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking request sent successfully!')),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Confirm Booking'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
