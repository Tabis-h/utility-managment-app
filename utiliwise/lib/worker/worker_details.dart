import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'booking.dart';

class WorkerDetailsScreen extends StatelessWidget {
  final String workerId;
  final String name;
  final String workType;
  final String workPrice;

  const WorkerDetailsScreen({
    Key? key,
    required this.workerId,
    required this.name,
    required this.workType,
    required this.workPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        elevation: 2,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .doc(workerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final workerData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        workType,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        'Contact Information',
                        Icons.phone,
                        workerData['mobile'] ?? 'Not provided',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Work Price',
                        Icons.attach_money,
                        '₹${workPrice}/hour',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Experience',
                        Icons.work_history,
                        '${workerData['experience'] ?? 'Not specified'} years',
                      ),
                      const SizedBox(height: 16),
                      _buildDescriptionSection(
                        workerData['description'] ?? 'No description provided',
                      ),
                      const SizedBox(height: 24),
                      _buildReviewsSection(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  workerId: workerId,
                  workerName: name,
                  workPrice: workPrice,
                ),
              ),
            );
          },
          child: Text('Book Now'),
        )
        ,
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('workers')
              .doc(workerId)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = snapshot.data!.docs;

            if (reviews.isEmpty) {
              return const Text('No reviews yet');
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review['userName'] ?? 'Anonymous',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                    (index) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < (review['rating'] ?? 0)
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review['comment'] ?? ''),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
