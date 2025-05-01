import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String workerUpiId;
  final double totalAmount;

  const PaymentScreen({
    Key? key,
    required this.workerId,
    required this.workerName,
    required this.workerUpiId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _initiateUpiPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create UPI payment link
      final uri = Uri.parse(
        'upi://pay?pa=${widget.workerUpiId}&pn=${widget.workerName}&am=${widget.totalAmount}&cu=INR&tn=Payment%20for%20service',
      );

      // Launch UPI app
      if (await canLaunch(uri.toString())) {
        await launch(uri.toString());
      } else {
        throw 'Could not launch UPI app';
      }

      // Wait for payment confirmation (manual for now)
      final paymentConfirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Confirmation'),
          content: const Text('Did you complete the payment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (paymentConfirmed == true) {
        // Process payment and save details
        await _processPayment();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        Navigator.pop(context); // Close the payment screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment not confirmed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final platformFee = widget.totalAmount * 0.20; // 20% platform fee
    final workerPayment = widget.totalAmount * 0.80; // 80% to the worker

    // Save payment details in Firestore
    await FirebaseFirestore.instance.collection('payments').add({
      'userId': userId,
      'workerId': widget.workerId,
      'totalAmount': widget.totalAmount,
      'platformFee': platformFee,
      'workerPayment': workerPayment,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update worker's earnings in Firestore
    final workerDoc = FirebaseFirestore.instance
        .collection('workers')
        .doc(widget.workerId);

    await workerDoc.update({
      'totalEarnings': FieldValue.increment(workerPayment),
      'pendingEarnings': FieldValue.increment(workerPayment),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay ${widget.workerName}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _initiateUpiPayment,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}