import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_clearance/Moderator/creator_home_page.dart';

class HistoryPage extends StatelessWidget {
  final String userID;

  HistoryPage({required this.userID});

  // Function to update status back to 'Pending'
  Future<void> _setStatusToPending(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .update({'status': 'Pending'});
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
                builder: (context) => ModeratorHomePage(userID: userID),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Requests')
            .where('status',
                isEqualTo: 'Approved') // Show only Approved requests
            .where('moderatorId', isEqualTo: userID) // Filter by moderatorId
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var approvedRequests = snapshot.data!.docs;

          if (approvedRequests.isEmpty) {
            return Center(child: Text('No approved requests yet.'));
          }

          return ListView.builder(
            itemCount: approvedRequests.length,
            itemBuilder: (context, index) {
              var request =
                  approvedRequests[index].data() as Map<String, dynamic>;
              String requestId = approvedRequests[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Colors.white.withOpacity(0.1), // Adjust the card opacity
                child: ListTile(
                  title: Text('Student ID: ${request['studentId']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Name: ${request['firstName']} ${request['lastName']}'),
                      Text('Status: ${request['status']}'),
                      SizedBox(
                          height:
                              4), // Add some space between the status and names
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _setStatusToPending(requestId); // Update status
                    },
                    child: Text('Back to Pending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor:
                          Colors.white, // Change the button color to blue
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
