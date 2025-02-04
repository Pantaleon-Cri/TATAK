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
    'Business Office',
    'Clinic',
    'Guidance',
    'Library',
  ];

  Map<String, String> requestStatus = {};

  @override
  void initState() {
    super.initState();
    if (widget.schoolId.isEmpty) {
      print('Error: School ID is empty');
      return;
    }
    _loadStudentInfo();
  }

  Future<void> _loadStudentInfo() async {
    try {
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
      // Store the request in Firestore with the status 'Pending'
      await FirebaseFirestore.instance.collection('Requests').add({
        'studentId': widget.schoolId,
        'office': office,
        'department': department,
        'college': college,
        'status': 'Pending',
      });

      // Fetch the updated request status from Firestore
      final requestQuery = await FirebaseFirestore.instance
          .collection('Requests')
          .where('studentId', isEqualTo: widget.schoolId)
          .where('office', isEqualTo: office)
          .get();

      if (requestQuery.docs.isNotEmpty) {
        final updatedRequest = requestQuery.docs.first.data();
        setState(() {
          requestStatus[office] = updatedRequest['status'];
        });
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  Widget _buildOfficeCard(String officeKey, String displayName) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.0),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: requestStatus[officeKey] == 'Pending'
                    ? null
                    : () => _requestToOffice(officeKey),
                child: Text(
                  requestStatus[officeKey] == 'Pending' ? 'Pending' : 'Request',
                ),
              ),
            ],
          ),
        ),
      ),
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
        title: Image.asset(
          'assets/tatak_logo.png',
          height: 40,
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: profileImageURL != null
                    ? NetworkImage(profileImageURL!)
                    : const AssetImage('assets/generic_avatar.png')
                        as ImageProvider,
              ),
              accountName: Text('$firstName $lastName'),
              accountEmail: Text(email),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 6, 109, 61),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return StudentProfileDialog(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                      department: department,
                      schoolId: widget.schoolId,
                      college: college,
                      club: club,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'OFFICES',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'CLEARANCE STATUS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: offices.length + 1, // +1 for Club
              itemBuilder: (context, index) {
                if (index < offices.length) {
                  final office = offices[index];
                  return _buildOfficeCard(office, office);
                } else {
                  return _buildOfficeCard('Club', 'Club - $department');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
