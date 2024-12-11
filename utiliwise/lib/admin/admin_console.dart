import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminConsole extends StatelessWidget {
  void _viewDocument(BuildContext context, String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(title),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Container(
              height: 400,
              width: double.maxFinite,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => launchUrl(Uri.parse(url)),
                        child: Text('Open in Browser'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Console')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workers')
            .where('kyc.status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final worker = snapshot.data!.docs[index];
              final kyc = worker.get('kyc');

              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Worker ID: ${worker.id}'),
                      Text('Document Type: ${kyc['documentType']}'),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _launchURL(kyc['documentUrl']),
                            child: Text('View Document'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _launchURL(kyc['selfieUrl']),
                            child: Text('View Selfie'),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _verifyKYC(worker.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text('Approve'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _rejectKYC(worker.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Reject'),
                          ),
                        ],
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

  Future<void> _verifyKYC(String workerId) async {
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .update({
      'kyc.status': 'verified',
      'kyc.verifiedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _rejectKYC(String workerId) async {
    await FirebaseFirestore.instance
        .collection('workers')
        .doc(workerId)
        .update({
      'kyc.status': 'rejected',
      'kyc.rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  void _launchURL(String url) async {
    // Add url_launcher package and implement URL opening
    // or display image in a dialog/new screen
  }
}
