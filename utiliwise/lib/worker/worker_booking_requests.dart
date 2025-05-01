import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../chat/chat_screen.dart';
import 'booking_details_page.dart';

class WorkerBookingRequests extends StatelessWidget {
  const WorkerBookingRequests({super.key});

  Stream<QuerySnapshot> get bookingRequestsStream => FirebaseFirestore.instance
      .collection('bookings')
      .where('workerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No booking requests found.'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final customerName = booking['customerName'] ?? 'Unknown';
              final serviceType = booking['serviceType'] ?? 'Unknown';
              final status = booking['status'] ?? 'Pending';
              final userId = booking['userId']; // Use the correct field name: userId

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(customerName),
                  subtitle: Text('Service: $serviceType\nStatus: $status'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chat),
                        onPressed: () {
                          // Navigate to the ChatScreen with the userId as the receiverId
                          if (userId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(receiverId: userId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User ID not found.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
