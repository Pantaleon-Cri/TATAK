import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../login_page.dart';
import 'functions.dart';
import 'settings.dart';

class ProfileDialog extends StatefulWidget {
  final String department;
  final String clubEmail;
  final String userID;
  final String college;
  final String category;
  final String subCategory;

  const ProfileDialog({
    super.key,
    required this.department,
    required this.clubEmail,
    required this.userID,
    required this.college,
    required this.category,
    required this.subCategory,
  });

  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  File? _profileImage;
  String? _profileImageURL;

  @override
  void initState() {
    super.initState();
    loadProfileImage(widget.userID, (url) {
      setState(() {
        _profileImageURL = url;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      backgroundColor: Colors.grey[200],
      child: FractionallySizedBox(
        widthFactor: 0.9,
        heightFactor: 0.85,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile Image (Avatar)
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
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Profile details with bold labels inside a rectangle
                      _buildProfileDetail('User ID:', widget.userID,
                          isBold: true),
                      _buildProfileDetail('College:', widget.college,
                          isBold: true),
                      _buildProfileDetail('Department:', widget.department,
                          isBold: true),
                      _buildProfileDetail('Email:', widget.clubEmail,
                          isBold: true),
                      _buildProfileDetail('Category:', widget.category,
                          isBold: true),
                      _buildProfileDetail('Sub-Category:', widget.subCategory,
                          isBold: true),

                      const SizedBox(height: 20),

                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            _modernButton(
                              context,
                              label: 'Settings',
                              icon: Icons.settings,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreatorSettingsPage(
                                      userID: widget.userID,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _modernButton(
                              context,
                              label: 'About Us',
                              icon: Icons.info,
                              onPressed: () {
                                Navigator.pop(context);
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Your App Name',
                                  applicationVersion: '1.0.0',
                                  applicationIcon: const Icon(Icons.info),
                                  children: const [
                                    Text(
                                        'This is the About Us section of the app.'),
                                  ],
                                );
                              },
                            ),
                            _modernButton(
                              context,
                              label: 'Logout',
                              icon: Icons.exit_to_app,
                              onPressed: () {
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Function to build profile detail with bold label inside a rectangle
  Widget _buildProfileDetail(String label, String value,
      {bool isBold = false}) {
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
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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

  Widget _modernButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              }, widget.userID);
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
              }, widget.userID);
            },
          ),
        ],
      ),
    );
  }
}
