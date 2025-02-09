import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_clearance/Admin/history_page.dart'; // HistoryPage for the navigation
import 'package:online_clearance/Admin/settings.dart';
import 'package:online_clearance/login_page.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<bool> _isButtonDisabled = [];

  // Fetching the users with 'pending' status from the Firestore
  Future<List<DocumentSnapshot>> _getPendingUsers() async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('moderators')
        .where('status', isEqualTo: 'pending') // Show only pending users
        .get();
    return querySnapshot.docs;
  }

  // Approve a user's account and update status to 'approved'
  Future<void> _approveAccount(String userId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('moderators')
          .doc(userId)
          .update({'status': 'approved'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account approved successfully')),
      );

      setState(() {
        _isButtonDisabled[index] = true; // Disable the button after approval
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving account: $e')),
      );
    }
  }

  // Decline a user's account and update status to 'declined'
  Future<void> _declineAccount(String userId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('moderators')
          .doc(userId)
          .update({'status': 'declined'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account declined successfully')),
      );

      setState(() {
        _isButtonDisabled[index] = true; // Disable the button after decline
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error declining account: $e')),
      );
    }
  }

  // Logout function
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 109, 61),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('Admin Dashboard'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('ADMIN Dashboard'), // Static name
              accountEmail: Text('Manage Account Below:'), // Static email
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 6, 109, 61),
              ),
            ),
            ListTile(
              leading: Icon(Icons.history), // History Icon
              title: Text('History'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to HistoryPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings), // Settings Icon
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to SettingsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout), // Logout Icon
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _logout(); // Call the logout function
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/tatak_logo.png'), // Background logo
            fit: BoxFit.contain,
          ),
        ),
        child: FutureBuilder<List<DocumentSnapshot>>(
          future: _getPendingUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No pending requests.'));
            }

            List<DocumentSnapshot> pendingUsers = snapshot.data!;
            _isButtonDisabled =
                List.generate(pendingUsers.length, (_) => false);

            return ListView.builder(
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                var user = pendingUsers[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 5,
                  child: ListTile(
                    title: Text(user['userID'] ?? 'Unknown'),
                    subtitle: Text(user['clubEmail'] ?? 'No email'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: _isButtonDisabled[index]
                              ? null
                              : () {
                                  _approveAccount(user.id, index);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text('Approve'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
