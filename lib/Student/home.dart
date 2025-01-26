import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_clearance/Student/profile.dart';

class StudentHomePage extends StatefulWidget {
  final String schoolId;

  const StudentHomePage({super.key, required this.schoolId});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String? profileImageURL;
  String firstName = 'Loading...';
  String lastName = 'Loading...';
  String email = 'Loading...';
  String department = 'Loading...';
  String college = 'Loading...';
  String club = 'Loading...';

  final List<String> offices = [
    'SSG',
    'COUNCIL',
    'DEAN',
    'DSA',
    'PEC',
    'Business',
    'Clinic',
    'Guidance',
    'Library'
  ];

  Map<String, String> requestStatus = {};

  @override
  void initState() {
    super.initState();
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    try {
      if (widget.schoolId.isEmpty) {
        print('Error: School ID is empty');
        return; // Exit early if schoolId is empty
      }

      final studentDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.schoolId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data();
        setState(() {
          firstName = data?['firstName'] ?? 'Student';
          lastName = data?['lastName'] ?? '';
          email = data?['email'] ?? 'Not Provided';
          profileImageURL = data?['profileImageURL'];
          department = data?['department'] ?? 'Not Provided';
          college = data?['college'] ?? 'Not Provided';
          club = data?['club'] ?? 'Not Provided';
        });
        print('Data loaded: $data'); // Debug: check if data is loaded correctly
      } else {
        print('Student document not found!');
      }
    } catch (e) {
      print('Error loading student info: $e');
    }
  }

  Future<void> _requestToOffice(String office) async {
    setState(() {
      requestStatus[office] = 'Pending';
    });

    try {
      await FirebaseFirestore.instance.collection('Requests').add({
        'studentId': widget.schoolId,
        'office': office,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Request to Office',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Roboto',
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 20,
              backgroundImage: profileImageURL != null
                  ? NetworkImage(profileImageURL!)
                  : const AssetImage('assets/placeholder_avatar.png')
                      as ImageProvider,
              child: profileImageURL == null
                  ? const Icon(Icons.person, size: 24, color: Colors.white)
                  : null,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return StudentProfileDialog(
                    firstName: firstName,
                    lastName: lastName,
                    email: email, // Pass email here
                    department: department, // Pass department here
                    schoolId: widget.schoolId,
                    college: college, // Pass college here
                    club: club, // Pass club here
                  );
                },
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: offices.length,
        itemBuilder: (context, index) {
          final office = offices[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    office,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: requestStatus[office] == 'Pending'
                        ? null
                        : () => _requestToOffice(office),
                    child: Text(
                      requestStatus[office] == 'Pending'
                          ? 'Pending'
                          : 'Request',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
