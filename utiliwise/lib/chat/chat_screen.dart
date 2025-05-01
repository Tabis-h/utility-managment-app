import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  final ScrollController _scrollController = ScrollController();



  // Fetch worker's UPI ID from Firestore
// Fetch worker's UPI ID from Firestore with proper ID verification
  Future<Map<String, dynamic>> _getWorkerDetails() async {
    try {
      // Use the current user's ID to get the worker's UPI ID
      final workerDoc = await _firestore
          .collection('workers')
          .doc(_auth.currentUser?.uid) // Using the correct worker ID
          .get();

      print('Worker ID being checked: ${_auth.currentUser?.uid}'); // Debug print
      print('Worker Data: ${workerDoc.data()}'); // Debug print

      if (workerDoc.exists) {
        return {
          'upi_id': workerDoc.data()?['upiId'],
          'name': workerDoc.data()?['name'] ?? 'Worker',
        };
      }
      return {'upi_id': null, 'name': 'Worker'};
    } catch (e) {
      print('Error fetching worker details: $e');
      return {'upi_id': null, 'name': 'Worker'};
    }
  }
// Add this debug method to verify IDs
  void _debugPrintIds() {
    print('Current User ID: ${_auth.currentUser?.uid}');
    print('Receiver ID: ${widget.receiverId}');
  }

  @override
  void initState() {
    super.initState();
    // Debug prints to verify IDs
    print('Current User ID: ${_auth.currentUser?.uid}');
    print('Receiver ID: ${widget.receiverId}');
  }



  // Initiate payment request
// Initiate payment request
  Future<void> _initiatePayment() async {
    final workerDetails = await _getWorkerDetails();

    if (workerDetails['upi_id'] == null || workerDetails['upi_id'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Worker has not added their UPI ID yet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final amountController = TextEditingController();
        return AlertDialog(
          title: const Text('Request Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: 8),
              Text('UPI ID: ${workerDetails['upi_id']}',
                  style: TextStyle(color: Colors.grey[600])
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, amountController.text),
              child: const Text('Request'),
            ),
          ],
        );
      },
    );

    if (amount != null && amount.isNotEmpty) {
      try {
        await _firestore.collection('messages').add({
          'sender_id': _auth.currentUser?.uid,
          'receiver_id': widget.receiverId,
          'message': 'Payment Request: ₹$amount',
          'type': 'payment_request',
          'amount': amount,
          'upi_id': workerDetails['upi_id'],
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create payment request: $e')),
        );
      }
    }
  }

  // Launch UPI app with payment details
  void _handlePayment(String amount, String upiId, String workerName) async {
    final upiUrl = 'upi://pay?pa=$upiId&pn=$workerName&am=$amount&cu=INR';
    final uri = Uri.parse(upiUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch UPI app')),
      );
    }
  }

  // Send normal message
  Future<void> _sendMessage() async {
    final String message = _messageController.text.trim();
    final String senderId = _auth.currentUser?.uid ?? '';

    if (message.isEmpty && _imageFile == null) return;

    try {
      await _firestore.collection('messages').add({
        'sender_id': senderId,
        'receiver_id': widget.receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      setState(() => _imageFile = null);

      // Scroll to bottom upon new message
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() => _imageFile = File(image.path));

        final fileName = 'chat_images/${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        final bytes = await image.readAsBytes();

        await supabase.storage
            .from('chat_images')
            .uploadBinary(fileName, bytes);

        final imageUrl = supabase.storage
            .from('chat_images')
            .getPublicUrl(fileName);

        await _sendImageMessage(imageUrl);
      }
    } catch (e) {
      print('Image upload error: $e');
    }
  }

  Future<void> _sendImageMessage(String imageUrl) async {
    final String senderId = _auth.currentUser?.uid ?? '';

    await _firestore.collection('messages').add({
      'sender_id': senderId,
      'receiver_id': widget.receiverId,
      'message': 'Image message',
      'image_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'image'
    });

    setState(() => _imageFile = null);
  }

  void _showDeleteOptions(String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete for me'),
                onTap: () {
                  _deleteMessageForMe(messageId);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete for everyone'),
                onTap: () {
                  _deleteMessageForEveryone(messageId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteMessageForMe(String messageId) async {
    await _firestore.collection('messages').doc(messageId).update({
      'deleted_for': FieldValue.arrayUnion([_auth.currentUser?.uid])
    });
  }

  Future<void> _deleteMessageForEveryone(String messageId) async {
    await _firestore.collection('messages').doc(messageId).delete();
  }


  // Format timestamp as 11:20 AM format
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      return 'Just now'; // Default fallback value
    }

    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
    }

    return 'Just now';
  }

  // Build message content depending on type (normal vs payment_request)
  Widget _buildMessageContent(Map<String, dynamic> message, bool isMe) {
    if (message['type'] == 'image') {
      return Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: 200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message['image_url'],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      );
    }
    if (message['type'] == 'payment_request') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Request',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Amount: ₹${message['amount']}'),
            Text('UPI ID: ${message['upi_id']}'),
            if (!isMe)
              ElevatedButton(
                onPressed: () {
                  _handlePayment(
                    message['amount'],
                    message['upi_id'], // Use the UPI ID from the message
                    'Service Provider', // You can customize this name
                  );
                },
                child: const Text('Pay Now'),
              ),

          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message['message'] != null)
          Text(
            message['message'],
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('sender_id', whereIn: [_auth.currentUser?.uid, widget.receiverId])
                  .where('receiver_id', whereIn: [_auth.currentUser?.uid, widget.receiverId])
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final deletedFor = List<String>.from(data['deleted_for'] ?? []);
                  return !deletedFor.contains(_auth.currentUser?.uid);
                }).toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isMe = message['sender_id'] == _auth.currentUser?.uid;
                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) {
                          _showDeleteOptions(messages[index].id);
                        }
                      },
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildMessageContent(message, isMe),
                              const SizedBox(height: 4),
                              Text(
                                _formatTimestamp(message['timestamp']),
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 12,
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
            )
            ,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.payment),
                  onPressed: _initiatePayment,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
