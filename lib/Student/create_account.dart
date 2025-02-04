import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_clearance/login_page.dart';
import 'package:online_clearance/registration_list.dart';

class StudentCreateAccount extends StatefulWidget {
  @override
  _StudentCreateAccountState createState() => _StudentCreateAccountState();
}

class _StudentCreateAccountState extends State<StudentCreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _schoolIdController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedCollege;
  String? _selectedDepartment;
  String? _selectedClub;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final schoolId = _schoolIdController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(schoolId)
            .get();

        if (doc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'ID already exists.',
                style: TextStyle(color: Colors.red),
              ),
              backgroundColor: Colors.white,
            ),
          );
        } else {
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(schoolId)
              .set({
            'schoolId': schoolId,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'college': _selectedCollege,
            'department': _selectedDepartment,
            'club': _selectedClub,
            'password': password, // Handle securely in production
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration successful!')));

          _clearFields();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }
    }
  }

  void _clearFields() {
    _schoolIdController.clear();
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _selectedCollege = null;
      _selectedDepartment = null;
      _selectedClub = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Registration')),
      body: Container(
        color: Color(0xFF167E55), // Set the background color here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _schoolIdController,
                  decoration: InputDecoration(
                    labelText: 'School ID',
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Student ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCollege,
                  hint: Text('Select College'),
                  items: ['CAS', 'CED', 'CEAC', 'CBA'].map((college) {
                    return DropdownMenuItem(
                      value: college,
                      child: Text(college),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCollege = value;
                      _selectedDepartment = null;
                      _selectedClub = null;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                ),
                SizedBox(height: 10),
                RegistrationList(
                  selectedCollege: _selectedCollege,
                  selectedDepartment: _selectedDepartment,
                  selectedClub: _selectedClub,
                  onCollegeChanged: (college) {
                    setState(() {
                      _selectedCollege = college;
                      _selectedDepartment = null;
                      _selectedClub = null;
                    });
                  },
                  onDepartmentChanged: (department) {
                    setState(() {
                      _selectedDepartment = department;
                      _selectedClub = null;
                    });
                  },
                  onClubChanged: (club) {
                    setState(() {
                      _selectedClub = club;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    filled: true, // Enable filling
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0B3F33), // Set button color
                    minimumSize: Size(double.infinity,
                        50), // Make the button longer and taller
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Optional: Rounded corners
                    ),
                  ),
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    // Adjust font size if needed
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
