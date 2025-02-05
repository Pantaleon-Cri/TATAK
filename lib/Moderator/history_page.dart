import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_clearance/Moderator/creator_home_page.dart';

class HistoryPage extends StatelessWidget {
  final String userID;

  HistoryPage({required this.userID});

  // Function to update the status back to 'Pending'
  Future<void> _setStatusToPending(String requestId) async {
    try {
      // Query the Requests collection for the document with the same requestId
      var requestSnapshot = await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .get();

      if (requestSnapshot.exists) {
        // Update the status to 'Pending' for the request
        await requestSnapshot.reference.update({
          'status': 'Pending',
        });
        print('Status updated to Pending');
      }
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
          icon: Icon(Icons.arrow_back), // Back button icon
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
            .collection('History')
            .where('approvedBy', isEqualTo: userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var historyRecords = snapshot.data!.docs;

          if (historyRecords.isEmpty) {
            return Center(child: Text('No approved requests yet.'));
          }

          return ListView.builder(
            itemCount: historyRecords.length,
            itemBuilder: (context, index) {
              var history =
                  historyRecords[index].data() as Map<String, dynamic>;
              String requestId = historyRecords[index].id; // Get the requestId

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Student ID: ${history['studentId']}'),
                  subtitle: Text('Status: ${history['status']}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      // Update the status of this request to 'Pending' in the Requests collection
                      await _setStatusToPending(requestId);

                      // Navigate back to the ModeratorHomePage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ModeratorHomePage(userID: userID),
                        ),
                      );
                    },
                    child: Text('Back to Pending'),
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
