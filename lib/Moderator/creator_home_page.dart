import 'package:flutter/material.dart';
import 'package:online_clearance/Moderator/history_page.dart';
import 'package:online_clearance/Moderator/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Set<String> approvedRequests = {}; // Store approved requests
  Set<String> excludedHistoryIds =
      {}; // Store history IDs that should be excluded

  @override
  void initState() {
    super.initState();
    _userDetails = _fetchUserDetails(widget.userID);
    _loadApprovedRequests(); // Load approved requests from SharedPreferences
    _loadExcludedHistoryIds(); // Load excluded history IDs
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

  // Load approved request IDs from SharedPreferences
  Future<void> _loadApprovedRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> approvedRequestsList =
        prefs.getStringList('approvedRequests') ?? [];
    setState(() {
      approvedRequests = Set<String>.from(approvedRequestsList);
    });
  }

  // Save approved request IDs to SharedPreferences
  Future<void> _saveApprovedRequest(String requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> approvedRequestsList =
        prefs.getStringList('approvedRequests') ?? [];
    approvedRequestsList.add(requestId);
    await prefs.setStringList('approvedRequests', approvedRequestsList);
  }

  // Load excluded history IDs from SharedPreferences
  Future<void> _loadExcludedHistoryIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> excludedIds = prefs.getStringList('excludedHistoryIds') ?? [];
    setState(() {
      excludedHistoryIds = Set<String>.from(excludedIds);
    });
  }

  // Save excluded history ID to SharedPreferences
  Future<void> _saveExcludedHistoryId(String requestId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> excludedIds = prefs.getStringList('excludedHistoryIds') ?? [];
    excludedIds.add(requestId);
    await prefs.setStringList('excludedHistoryIds', excludedIds);
  }

  // Update request status to 'Approved' and move to history
  Future<void> _updateRequestStatus(
      String requestId, Map<String, dynamic> requestData) async {
    try {
      // Copy request data to History collection
      await FirebaseFirestore.instance
          .collection('History')
          .doc(requestId)
          .set({
        ...requestData, // Copy all request data
        'status': 'Approved', // Mark as approved
        'approvedBy': widget.userID, // Store moderator who approved it
        'timestamp': FieldValue.serverTimestamp(), // Save approval time
      });

      // Update the status in Requests collection without deleting
      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(requestId)
          .update({
        'status': 'Approved',
      });

      // Save to SharedPreferences
      await _saveApprovedRequest(requestId);

      // Add the request ID to excluded history IDs
      await _saveExcludedHistoryId(requestId);

      setState(() {
        approvedRequests.add(requestId);
        excludedHistoryIds.add(requestId); // Update the excluded set
      });
    } catch (e) {
      print('Error updating request: $e');
    }
  }

  // Filter requests to exclude approved ones
  Stream<QuerySnapshot> _applyFilters() {
    var query = FirebaseFirestore.instance
        .collection('Requests')
        .where('office', isEqualTo: category)
        .where('status', isEqualTo: 'Pending'); // Only show pending requests

    if (category == 'SSG' ||
        category == 'DSA' ||
        category == 'PEC' ||
        category == 'Business Office' ||
        category == 'Clinic' ||
        category == 'Library') {
      return query.snapshots();
    }
    if (category == 'COUNCIL' || category == 'DEAN' || category == 'Guidance') {
      return query.where('college', isEqualTo: college ?? '').snapshots();
    }
    if (category == 'Club') {
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
        actions: [],
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
                ListTile(
                  leading: Icon(Icons.history), // History Icon
                  title: Text('History'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HistoryPage(userID: widget.userID),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _applyFilters(),
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
              String requestId = requests[index].id;

              // Skip the request if it's already in the excluded list
              if (excludedHistoryIds.contains(requestId)) {
                return SizedBox.shrink();
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Student ID: ${request['studentId']}'),
                  subtitle: Text('Status: ${request['status']}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await _updateRequestStatus(requestId, request);
                    },
                    child: Text('Approve'),
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
