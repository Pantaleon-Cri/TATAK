import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_clearance/login_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<bool> _isButtonDisabled = [];

  // Function to fetch users with 'pending' approval status
  Future<List<DocumentSnapshot>> _getPendingUsers() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('approvalStatus', isEqualTo: 'pending')
        .get();
    return querySnapshot.docs;
  }

  // Function to approve a user's account
  Future<void> _approveAccount(String userId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'approvalStatus': 'approved'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account approved successfully')),
      );

      setState(() {
        _isButtonDisabled[index] = true; // Disable buttons after approval
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving account: $e')),
      );
    }
  }

  // Function to decline a user's account
  Future<void> _declineAccount(String userId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'approvalStatus': 'declined'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account declined successfully')),
      );

      setState(() {
        _isButtonDisabled[index] = true; // Disable buttons after decline
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining account: $e')),
      );
    }
  }

  // Function to handle logout
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // Remove all routes to ensure logout is clean
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Logout action
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getPendingUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pending requests.'));
          }

          List<DocumentSnapshot> pendingUsers = snapshot.data!;
          _isButtonDisabled = List.generate(pendingUsers.length, (_) => false);

          return ListView.builder(
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              var user = pendingUsers[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                child: ListTile(
                  title: Text(user['creatorName'] ?? 'Unknown'),
                  subtitle: Text(user['email'] ?? 'No email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _isButtonDisabled[index]
                            ? null
                            : () {
                                _approveAccount(
                                    user.id, index); // Approve action
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Approve'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isButtonDisabled[index]
                            ? null
                            : () {
                                _declineAccount(
                                    user.id, index); // Decline action
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Decline'),
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
}
