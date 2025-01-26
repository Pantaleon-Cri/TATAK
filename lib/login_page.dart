import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_clearance/Admin/admin_homepage.dart';
import 'package:online_clearance/Moderator/creator_home_page.dart';
import 'package:online_clearance/Student/home.dart';
import 'create_account_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // For toggling password visibility

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final id = _idController.text.trim();
        final password = _passwordController.text.trim();

        // Admin login check
        if (id == 'admin' && password == '1234') {
          // Create admin collection in Firestore
          await FirebaseFirestore.instance
              .collection('admin')
              .doc('adminDoc')
              .set({
            'lastLogin': DateTime.now().toIso8601String(),
          });

          // Navigate to AdminPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(),
            ),
          );
          return; // Exit the function as the admin login is handled
        }

        DocumentSnapshot userDoc;

        if (id.startsWith('c')) {
          // Check in the Users collection for creators
          userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(id)
              .get();
        } else {
          // Check in the Users collection for students
          userDoc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(id)
              .get();
        }

        if (userDoc.exists) {
          String storedPassword = userDoc['password'];

          if (storedPassword == password) {
            if (id.startsWith('c')) {
              // For creator accounts
              String approvalStatus = userDoc['approvalStatus'];
              if (approvalStatus == 'accepted') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModeratorHomePage(),
                  ),
                );
              } else {
                // Account is not accepted
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account not accepted yet.')),
                );
              }
            } else {
              // For student accounts
              String schoolId = userDoc['schoolId']; // Retrieve the schoolId
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentHomePage(
                    schoolId: schoolId, // Pass the actual schoolId
                  ),
                ),
              );
            }
            return; // Exit the function if login is successful
          } else {
            // Incorrect password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect password.')),
            );
            return; // Exit if password is incorrect
          }
        } else {
          // ID not found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ID not found.')),
          );
        }
      } catch (e) {
        // Handle any errors that occur during login
        print('Error during login: $e'); // Debug log for developers
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
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
                                  hintText: 'School ID', // Placeholder text
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  prefixIcon: Icon(Icons.person),
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
                                  prefixIcon: Icon(Icons.lock),
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
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                  ),
                                  child: Text(
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
                                    style: TextStyle(color: Colors.white),
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
                                        color: Colors.white,
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
