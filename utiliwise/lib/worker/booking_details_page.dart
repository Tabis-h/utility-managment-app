import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsPage extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingDetailsPage({
    Key? key,
    required this.bookingId,
    required this.bookingData,
  }) : super(key: key);

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final TextEditingController _priceController = TextEditingController();

  Future<void> updateBookingStatus(String status) async {
    if (status == 'accepted' && _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the cost before accepting the booking.')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({
      'status': status,
      'price': _priceController.text,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send notification to user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.bookingData['userId'])
        .collection('notifications')
        .add({
      'type': 'booking_update',
      'bookingId': widget.bookingId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'title': 'Booking Status Updated',
      'message': 'Your booking status has been updated to $status',
      'workerId': widget.bookingData['workerId'],
    });

    if (status == 'accepted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking accepted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking rejected successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime bookingDate = (widget.bookingData['date'] as Timestamp).toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(widget.bookingData['customerName'] ?? 'Unknown'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(widget.bookingData['address']),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('Date: ${bookingDate.toString().split(' ')[0]}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text('Time: ${widget.bookingData['time']}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: Text('Description: ${widget.bookingData['description']}'),
                    ),
                    if (widget.bookingData['status'] == 'pending')
                      TextField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Cost',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    if (widget.bookingData['status'] != 'pending')
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: Text('Price: ${widget.bookingData['price']}'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.bookingData['status'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => updateBookingStatus('accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () => updateBookingStatus('rejected'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
