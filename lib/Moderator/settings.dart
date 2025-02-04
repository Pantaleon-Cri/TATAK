import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatorSettingsPage extends StatefulWidget {
  final String userID; // Club email to identify the creator

  const CreatorSettingsPage({super.key, required this.userID});

  @override
  _CreatorSettingsPageState createState() => _CreatorSettingsPageState();
}

class _CreatorSettingsPageState extends State<CreatorSettingsPage> {
  final _emailController = TextEditingController();
  final _updateEmailController = TextEditingController();
  late String currentEmail;

  bool _isPasswordVisible = false;
  late String _password = '';
  late String _newPassword = '';
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserDetails(); // Fetch current user details on init
  }

  // Fetch creator's current information
  void _fetchCurrentUserDetails() async {
    try {
      final moderatorDoc = await FirebaseFirestore.instance
          .collection('moderators')
          .doc(widget.userID)
          .get();

      if (moderatorDoc.exists) {
        setState(() {
          currentEmail = moderatorDoc['clubEmail'] ?? '';
          _password = moderatorDoc.data()?['password'] ?? '';
          _emailController.text = currentEmail;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching creator details: $e')),
      );
    }
  }

  bool _isValidEmail(String email) {
    return email.contains('@'); // Check if email contains '@'
  }

  Future<void> _updateEmailInFirestore() async {
    String newEmail = _updateEmailController.text.trim();

    if (newEmail.isEmpty || !_isValidEmail(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    try {
      // Update the email in the Users collection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userID)
          .update({'email': newEmail});

      // Optionally, update the email in Firebase Authentication (if the user is logged in)
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user
            .updateEmail(newEmail); // Update email in Firebase Authentication
        await user.reload();
      }

      // Update the email in all posts belonging to this clubId
      await FirebaseFirestore.instance
          .collection('moderators')
          .where('userID', isEqualTo: widget.userID) // Target posts by clubId
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'email': newEmail});
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully')),
      );
    } catch (error) {
      print('Error updating email: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update email: $error')),
      );
    }
  }

  Future<void> _updatePasswordInFirebase() async {
    if (_newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new password')),
      );
      return;
    }

    try {
      // Update the password in Firebase
      await FirebaseFirestore.instance
          .collection('moderators')
          .doc(widget.userID)
          .update({'password': _newPassword});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (error) {
      print('Error updating password: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Editable TextFormField to update email
            TextFormField(
              controller: _emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _updateEmailController,
              decoration: const InputDecoration(
                labelText: "New Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to save profile changes
            ElevatedButton(
              onPressed: _updateEmailInFirestore,
              child: const Text('Save Email Changes'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
            const SizedBox(height: 20),

            // Password field with visibility toggle
            TextFormField(
              controller: TextEditingController(text: _password),
              obscureText: !_isPasswordVisible,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                hintText: "Your current password",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // New password field
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isPasswordVisible,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Button to save password changes
            ElevatedButton(
              onPressed: () async {
                _newPassword =
                    _newPasswordController.text; // Set the new password
                await _updatePasswordInFirebase(); // Update password
              },
              child: const Text('Save Password Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
