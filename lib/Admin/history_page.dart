import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_clearance/Admin/admin_homepage.dart'; // AdminPage to navigate back

class HistoryPage extends StatelessWidget {
  // Function to set the status back to 'Pending'
  Future<void> _setStatusToPending(String moderatorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('moderators')
          .doc(moderatorId)
          .update({'status': 'pending'});
      print('Status updated to Pending');
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF167E55),
        title: Text('History'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AdminPage(), // Go back to AdminPage
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('moderators')
            .where('status',
                isEqualTo: 'approved') // Show only approved moderators
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var approvedModerators = snapshot.data!.docs;

          if (approvedModerators.isEmpty) {
            return Center(child: Text('No approved requests yet.'));
          }

          return ListView.builder(
            itemCount: approvedModerators.length,
            itemBuilder: (context, index) {
              var moderator =
                  approvedModerators[index].data() as Map<String, dynamic>;
              String moderatorId = approvedModerators[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white.withOpacity(0.1), // Adjust the card opacity
                child: ListTile(
                  title: Text('Name: ${moderator['userID']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Club Email: ${moderator['clubEmail']}'),
                      Text('Status: ${moderator['status']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _setStatusToPending(
                          moderatorId); // Update status back to 'Pending'
                    },
                    child: Text('Back to Pending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white, // Change button color
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
}
