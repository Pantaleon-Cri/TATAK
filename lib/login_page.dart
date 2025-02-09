import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_clearance/Admin/admin_homepage.dart';
import 'package:online_clearance/Student/home.dart';
import 'package:online_clearance/Moderator/creator_home_page.dart'; // Moderator's home page
import 'create_account_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // For toggling password visibility

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        final id = _idController.text.trim();
        final password = _passwordController.text.trim();

        // Check in the Users collection for students
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('Users').doc(id).get();

        if (userDoc.exists) {
          String storedPassword = userDoc['password'];

          if (storedPassword == password) {
            String schoolId = userDoc['schoolId']; // Retrieve the schoolId
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomePage(
                  schoolId: schoolId, // Pass the actual schoolId
                ),
              ),
            );
            return; // Exit the function if login is successful
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect password.')),
            );
            return;
          }
        } else {
          // ID not found in Users collection, check for moderators
          DocumentSnapshot moderatorDoc = await FirebaseFirestore.instance
              .collection('moderators')
              .doc(id)
              .get();

          if (moderatorDoc.exists) {
            String storedUserID = moderatorDoc['userID'];
            String storedPassword = moderatorDoc['password'];
            String status = moderatorDoc['status']; // Retrieve the status

            if (storedUserID == id && storedPassword == password) {
              if (status == 'approved') {
                String userID = moderatorDoc['userID'];
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModeratorHomePage(
                      userID: userID,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Your account is pending approval.')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incorrect userID or password.')),
              );
            }
          } else {
            // Check for admin credentials
            DocumentSnapshot adminDoc = await FirebaseFirestore.instance
                .collection('admin')
                .doc('adminDoc')
                .get();

            if (adminDoc.exists) {
              String storedAdminID = adminDoc['adminId'];
              String storedAdminPassword = adminDoc['password'];

              if (id == storedAdminID && password == storedAdminPassword) {
                await FirebaseFirestore.instance
                    .collection('admin')
                    .doc('adminDoc')
                    .set({
                  'lastLogin': DateTime.now().toIso8601String(),
                }, SetOptions(merge: true));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPage(),
                  ),
                );
                return;
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Incorrect admin ID or password.')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ID not found.')),
              );
            }
          }
        }
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading after login attempt
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents layout distortion when keyboard appears
      body: Stack(
        fit: StackFit.expand, // Ensures the background covers the whole screen
        children: [
          // Background image using Network Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ndmu.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Vertically center the content
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Horizontally center the content
              children: [
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.85, // 85% width of the screen
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight *
                            0.30, // Dynamically adjust top padding
                        bottom: MediaQuery.of(context)
                            .viewInsets
                            .bottom, // Adjust for keyboard
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black
                              .withOpacity(0.3), // Transparent background
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3), // Soft border
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Heading
                              Text(
                                'Tatak',
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.08, // Adjust font size dynamically
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20),
                              // Username/ID Input Field
                              TextFormField(
                                controller: _idController,
                                decoration: InputDecoration(
                                  hintText:
                                      'School ID/User ID', // Placeholder text
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Username';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              // Password Input Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password', // Placeholder text
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              SizedBox(height: 5),
                              // Sign In Button
                              SizedBox(
                                width: screenWidth * 0.5, // Adjust button width
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _login, // Disable button when loading
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                      : Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth *
                                                0.05, // Adjust font size
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 5),
                              // Sign Up Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t Have Account?',
                                    style: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CreateAccountPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: screenWidth * 0.04,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
