import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

          if (bookings.isEmpty) {
            return Center(child: Text('No pending booking requests'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              // Print booking data for debugging
              print('Booking data: $booking');

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

  String _formatDateTime() {
    try {
      // Print the date-related fields for debugging
      print('Formatted Date: ${booking['formattedDate']}');
      print('DateTime: ${booking['datetime']}');
      print('Date: ${booking['date']}');

      // Check if we have the formatted date string
      if (booking['formattedDate'] != null) {
        return booking['formattedDate'];
      }

      // Check for datetime field
      if (booking['datetime'] != null) {
        final Timestamp timestamp = booking['datetime'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();
        return DateFormat('MMMM dd, yyyy').format(dateTime);
      }

      // Check for date field that might be a Timestamp
      if (booking['date'] != null) {
        if (booking['date'] is Timestamp) {
          final Timestamp timestamp = booking['date'] as Timestamp;
          final DateTime dateTime = timestamp.toDate();
          return DateFormat('MMMM dd, yyyy').format(dateTime);
        }
        // If date is already a formatted string
        return booking['date'].toString();
      }

      return 'Date not available';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Error displaying date';
    }
  }

  String _formatTime() {
    try {
      // Print the time-related fields for debugging
      print('Formatted Time: ${booking['formattedTime']}');
      print('Time: ${booking['time']}');

      // Check for formatted time string
      if (booking['formattedTime'] != null) {
        return booking['formattedTime'];
      }

      // Check for datetime field
      if (booking['datetime'] != null) {
        final Timestamp timestamp = booking['datetime'] as Timestamp;
        final DateTime dateTime = timestamp.toDate();
        return DateFormat('hh:mm a').format(dateTime);
      }

      // Use time field if available
      if (booking['time'] != null) {
        return booking['time'].toString();
      }

      return 'Time not available';
    } catch (e) {
      print('Error formatting time: $e');
      return 'Error displaying time';
    }
  }

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
            Text('Customer: ${booking['customerName'] ?? 'Unknown'}'),
            Text('Date: ${_formatDateTime()}'),
            Text('Time: ${_formatTime()}'),
            Text('Address: ${booking['address']}'),
            Text('Description: ${booking['description']}'),
            if (booking['price'] != null)
              Text('Price: ${booking['price']}'),
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