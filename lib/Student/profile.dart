import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../login_page.dart';
import 'functions.dart';
import 'settings.dart';

class StudentProfileDialog extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String college;
  final String department;
  final String club;
  final String schoolId;

  const StudentProfileDialog({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.department,
    required this.schoolId,
    required this.college,
    required this.club,
  });

  @override
  _StudentProfileDialogState createState() => _StudentProfileDialogState();
}

class _StudentProfileDialogState extends State<StudentProfileDialog> {
  File? _profileImage;
  String? _profileImageURL;

  @override
  void initState() {
    super.initState();
    if (widget.schoolId.isEmpty) {
      print('Error: School ID is empty');
      return; // Exit early if schoolId is empty
    }
    _loadProfileImage(widget.schoolId);
  }

  // Loads the profile image from a URL if it exists
  void _loadProfileImage(String schoolId) {
    loadProfileImage(schoolId, (url) {
      setState(() {
        _profileImageURL = url;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.9,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _showImageSourceSelection(context);
                          },
                          child: CircleAvatar(
                            radius: constraints.maxWidth * 0.15,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : _profileImageURL != null
                                    ? NetworkImage(_profileImageURL!)
                                    : const AssetImage(
                                            'assets/generic_avatar.png')
                                        as ImageProvider,
                            backgroundColor: Colors.grey[400],
                            child: _profileImage == null &&
                                    _profileImageURL == null
                                ? const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.white70,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileDetail(
                          'Name:', '${widget.firstName} ${widget.lastName}'),
                      _buildProfileDetail('Email:', widget.email),
                      _buildProfileDetail('College:', widget.college),
                      _buildProfileDetail('Department:', widget.department),
                      _buildProfileDetail('Club:', widget.club),
                      _buildProfileDetail('School ID:', widget.schoolId),
                      const SizedBox(height: 20),
                      Divider(),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                schoolId: widget.schoolId,
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to show image source options (Gallery/Camera)
  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.gallery, (image) {
                setState(() {
                  _profileImage = image;
                });
              }, (url) {
                setState(() {
                  _profileImageURL = url;
                });
              }, widget.schoolId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              pickImage(ImageSource.camera, (image) {
                setState(() {
                  _profileImage = image;
                });
              }, (url) {
                setState(() {
                  _profileImageURL = url;
                });
              }, widget.schoolId);
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create profile detail with bold labels inside a rectangle
  Widget _buildProfileDetail(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
