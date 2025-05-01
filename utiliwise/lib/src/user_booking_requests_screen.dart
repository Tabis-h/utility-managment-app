import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../chat/chat_screen.dart';

class UserBookingRequestsScreen extends StatelessWidget {
  const UserBookingRequestsScreen({super.key});

  String formatDate(dynamic dateField) {
    try {
      if (dateField is Timestamp) {
        return DateFormat('yyyy-MM-dd').format(dateField.toDate());
      } else if (dateField is String) {
        return dateField;
      } else if (dateField is DateTime) {
        return DateFormat('yyyy-MM-dd').format(dateField);
      }
      return 'Date not available';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Date not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No booking requests found.'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final bookingId = bookings[index].id;

              return GestureDetector(
                onTap: () {
                  // Navigate to the chat screen only if the booking is accepted
                  if (booking['status'] == 'accepted') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: booking['workerId'],
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ID: $bookingId',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Date: ${formatDate(booking['date'])}'),
                        Text('Time: ${booking['time'] ?? 'Time not available'}'),
                        Text('Worker: ${booking['workerName'] ?? 'Not assigned'}'),
                        Text('Description: ${booking['description']}'),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${booking['status']}',
                          style: TextStyle(
                            color: _getStatusColor(booking['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (booking['price'] != null)
                          Text(
                            'Amount: ₹${booking['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        if (booking['status'] == 'accepted')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Tap to chat with worker',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'declined':
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}