import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_clearance/Moderator/profile.dart';

class ModeratorHomePage extends StatefulWidget {
  final String userID;

  ModeratorHomePage({required this.userID});

  @override
  _ModeratorHomePageState createState() => _ModeratorHomePageState();
}

class _ModeratorHomePageState extends State<ModeratorHomePage> {
  late Future<Map<String, dynamic>> _userDetails;
  String? category;
  String? subCategory;
  String? department;
  String? college;

  @override
  void initState() {
    super.initState();
    _userDetails = _fetchUserDetails(widget.userID);
  }

  Future<Map<String, dynamic>> _fetchUserDetails(String userID) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('moderators')
          .doc(userID)
          .get();

      var data = userDoc.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          category = data['category'];
          subCategory = data['subCategory'];
          department = data['department'];
          college = data['college'];
        });
      }
      return data ?? {};
    } catch (e) {
      print('Error fetching user data: $e');
      return {};
    }
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      // Update the request status in the Requests collection
      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .update({'status': newStatus});
    } catch (e) {
      print('Error updating request status: $e');
    }
  }

  // Function to apply filters based on the category
  Stream<QuerySnapshot> _applyFilters() {
    var query = FirebaseFirestore.instance
        .collection('Requests')
        .where('office', isEqualTo: category);

    if (category == 'SSG' ||
        category == 'DSA' ||
        category == 'PEC' ||
        category == 'Business Office' ||
        category == 'Clinic' ||
        category == 'Library') {
      // No college or department required
      return query.snapshots();
    }
    if (category == 'COUNCIL' || category == 'DEAN' || category == 'Guidance') {
      // College required, no department
      return query.where('college', isEqualTo: college ?? '').snapshots();
    }
    if (category == 'Club') {
      // Both college and department required
      return query
          .where('college', isEqualTo: college ?? '')
          .where('department', isEqualTo: department ?? '')
          .snapshots();
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF167E55),
        title: Text('Moderator Home'),
        centerTitle: true,
      ),
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _userDetails,
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          var userData = snapshot.data!;
          return Drawer(
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(widget.userID),
                  accountEmail: Text(userData['clubEmail'] ?? 'Not Provided'),
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 6, 109, 61)),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ProfileDialog(
                          department: userData['department'] ?? 'Not Provided',
                          clubEmail: userData['clubEmail'] ?? 'Not Provided',
                          userID: widget.userID,
                          college: userData['college'] ?? 'Not Provided',
                          category: category ?? 'Not Provided',
                          subCategory: subCategory ?? 'Not Provided',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _applyFilters(), // Corrected here, using the method that returns Stream<QuerySnapshot>
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return Center(
                child: Text('No requests available for your office.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Student ID: ${request['studentId']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await _updateRequestStatus(
                            requests[index].id,
                            'Approved',
                          );
                        },
                        child: Text('Approve'),
                      ),
                      SizedBox(width: 8),
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
