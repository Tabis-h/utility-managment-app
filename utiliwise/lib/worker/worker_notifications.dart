import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WorkerNotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Booking Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('workerId', isEqualTo: workerId)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;

              return BookingRequestCard(
                booking: booking,
                onAccept: () => _handleBooking(booking['bookingId'], 'accepted'),
                onDecline: () => _handleBooking(booking['bookingId'], 'declined'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleBooking(String bookingId, String status) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }
}

class BookingRequestCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const BookingRequestCard({
    required this.booking,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Booking Request',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Date: ${booking['date']}'),
            Text('Time: ${booking['time']}'),
            Text('Address: ${booking['address']}'),
            Text('Description: ${booking['description']}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDecline,
                  child: Text('Decline'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccept,
                  child: Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
