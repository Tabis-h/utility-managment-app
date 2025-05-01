import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Main widget
class AdminConsole extends StatefulWidget {
  const AdminConsole({super.key});

  @override
  State<AdminConsole> createState() => _AdminConsoleState();
}

// Worker model to handle data parsing
class Worker {
  final String id;
  final String name;
  final String status;
  final String documentType;
  final String documentUrl;
  final String selfieUrl;
  final DateTime? timestamp;

  Worker({
    required this.id,
    required this.name,
    required this.status,
    required this.documentType,
    required this.documentUrl,
    required this.selfieUrl,
    this.timestamp,
  });

  factory Worker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Handle nested data structure
    final kyc = data['kyc'] as Map<String, dynamic>? ?? {};
    final status = kyc['status'] as String? ?? 'pending';

    return Worker(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown',
      status: status,
      documentType: kyc['documentType'] as String? ?? 'Unknown',
      documentUrl: kyc['documentUrl'] as String? ?? '',
      selfieUrl: kyc['selfieUrl'] as String? ?? '',
      timestamp: (kyc['${status}At'] as Timestamp?)?.toDate(),
    );
  }
}

class _AdminConsoleState extends State<AdminConsole> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Image viewer dialog
  void _viewDocument(BuildContext context, String url, String title) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document URL is not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: size.width * 0.7,
          height: size.height * 0.8,
          child: Column(
            children: [
              AppBar(
                title: Text(title),
                centerTitle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () => _launchURL(url),
                    tooltip: 'Open in new tab',
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          const Text('Failed to load image'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _launchURL(url),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open in Browser'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  // KYC verification functions
  Future<void> _verifyKYC(BuildContext context, String workerId) async {
    try {
      await FirebaseFirestore.instance.collection('workers').doc(workerId).update({
        'kyc.status': 'verified',
        'kyc.verifiedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC verified successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error verifying KYC: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying KYC: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectKYC(BuildContext context, String workerId) async {
    try {
      await FirebaseFirestore.instance.collection('workers').doc(workerId).update({
        'kyc.status': 'rejected',
        'kyc.rejectedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC rejected'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error rejecting KYC: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting KYC: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Worker card widget
  Widget _buildWorkerCard(Worker worker, bool showActions) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    worker.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: worker.status == 'pending' ? Colors.orange.shade100 :
                    worker.status == 'verified' ? Colors.green.shade100 :
                    Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    worker.status.toUpperCase(),
                    style: TextStyle(
                      color: worker.status == 'pending' ? Colors.orange.shade900 :
                      worker.status == 'verified' ? Colors.green.shade900 :
                      Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.description_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Document Type: ${worker.documentType}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            if (worker.timestamp != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${worker.status.capitalize()} at: ${worker.timestamp.toString().split('.').first}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDocument(
                      context,
                      worker.documentUrl,
                      'Document',
                    ),
                    icon: const Icon(Icons.file_present),
                    label: const Text('Document'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDocument(
                      context,
                      worker.selfieUrl,
                      'Selfie',
                    ),
                    icon: const Icon(Icons.face),
                    label: const Text('Selfie'),
                  ),
                ),
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _verifyKYC(context, worker.id),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectKYC(context, worker.id),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Main list builder
  Widget _buildWorkerList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workers')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading data: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final workers = snapshot.data!.docs
            .map((doc) => Worker.fromFirestore(doc))
            .where((worker) => worker.status == status)
            .toList();

        if (workers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending' ? Icons.pending_actions :
                  status == 'verified' ? Icons.check_circle_outline :
                  Icons.cancel_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No $status KYC verifications',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 1400 ? 3 :
            constraints.maxWidth > 900 ? 2 : 1;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                return _buildWorkerCard(
                  workers[index],
                  status == 'pending',
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        centerTitle: true,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions),
              text: 'Pending',
            ),
            Tab(
              icon: Icon(Icons.check_circle),
              text: 'Verified',
            ),
            Tab(
              icon: Icon(Icons.cancel),
              text: 'Rejected',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkerList('pending'),
          _buildWorkerList('verified'),
          _buildWorkerList('rejected'),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}