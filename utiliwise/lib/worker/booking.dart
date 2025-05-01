import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  final _formKey = GlobalKey<FormState>();

  Future<void> createBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final bookingId = FirebaseFirestore.instance.collection('bookings').doc().id;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final customerName = userDoc['name'] ?? 'Unknown';

    // Format date and time as strings
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final String formattedTime = selectedTime!.format(context);

    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set({
      'bookingId': bookingId,
      'userId': userId,
      'customerName': customerName,
      'workerId': widget.workerId,
      'workerName': widget.workerName,
      'status': 'pending',
      'date': formattedDate, // Store only the date as string
      'time': formattedTime, // Store time separately
      'address': addressController.text,
      'description': descriptionController.text,
      'serviceType': widget.workerName,
      'price': widget.workPrice,
      'createdAt': FieldValue.serverTimestamp(),
      'userNotified': true,
    });

    await FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId)
        .collection('notifications')
        .add({
      'type': 'new_booking',
      'bookingId': bookingId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'title': 'New Booking Request',
      'message': 'You have a new booking request',
      'userId': userId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request sent successfully!')),
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(selectedDate!) // Changed date format here as well
                        : 'No date selected',
                  ),
                  trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 4,
                child: ListTile(
                  title: const Text('Select Time', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'No time selected',
                  ),
                  trailing: const Icon(Icons.access_time, color: Colors.blue),
                  onTap: () => _selectTime(context),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Service Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the service address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Problem Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description, color: Colors.blue),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the problem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a date and time')),
                      );
                      return;
                    }

                    final confirmed = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Booking'),
                        content: const Text('Are you sure you want to book this service?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await createBooking();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}