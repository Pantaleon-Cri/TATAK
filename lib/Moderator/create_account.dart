import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorCreateAccount extends StatefulWidget {
  @override
  _CreatorCreateAccountState createState() => _CreatorCreateAccountState();
}

class _CreatorCreateAccountState extends State<CreatorCreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clubnameController = TextEditingController();
  final TextEditingController _clubEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _userIDController = TextEditingController();

  String? _selectedCollege;
  String? _selectedDepartment;

  String? _selectedCategory;
  String? _selectedSubCategory;

  Future<void> _saveToFirestore() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('moderators')
            .doc(_userIDController.text)
            .set({
          'clubName': _clubnameController.text,
          'clubEmail': _clubEmailController.text,
          'password': _passwordController.text,
          'userID': _userIDController.text,
          'college': _selectedCollege,
          'department': _selectedDepartment,
          'category': _selectedCategory,
          'subCategory': _selectedSubCategory,
          'status': 'pending', // Set status to 'pending'
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account successfully registered!')),
        );
        _clearFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  // Reset all fields
  void _clearFields() {
    _clubnameController.clear();
    _clubEmailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _userIDController.clear();
    setState(() {
      _selectedCollege = null;
      _selectedDepartment = null;
      _selectedCategory = null;
      _selectedSubCategory = null;
    });
  }

  // Function to approve or deny a moderator registration in admin panel

  // Function to handle moderator sign-in

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Moderator Registration')),
      body: SingleChildScrollView(
        child: Container(
          color: Color(0xFF167E55),
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text('Select Category'),
                  items: [
                    'SSG',
                    'COUNCIL',
                    'DEAN',
                    'DSA',
                    'PEC',
                    'Business Office',
                    'Clinic',
                    'Guidance',
                    'Library',
                    'Club',
                  ].map((category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedCollege = null;
                      _selectedDepartment = null;
                      _selectedSubCategory = null;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                // Additional Dropdowns for College/Department/Subcategory...
                if (_selectedCategory == 'COUNCIL' ||
                    _selectedCategory == 'DEAN' ||
                    _selectedCategory == 'Guidance') ...[
                  DropdownButtonFormField<String>(
                    value: _selectedCollege,
                    hint: Text('Select College'),
                    items: ['CEAC', 'CBA', 'CAS', 'CED'].map((college) {
                      return DropdownMenuItem(
                        value: college,
                        child: Text(college),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCollege = value;
                        _selectedDepartment = null;
                        _selectedSubCategory = null;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
                if (_selectedCategory == 'Club') ...[
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
                        _selectedSubCategory = null;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  if (_selectedCollege == 'CED') ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: Text('Select Department'),
                      items: ['Natural Science', 'RE'].map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          _selectedSubCategory = null;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                  if (_selectedCollege == 'CBA') ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: Text('Select Department'),
                      items: [
                        'Department of Business 1',
                        'Department of Administration 1'
                      ].map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          _selectedSubCategory = null;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                  if (_selectedCollege == 'CEAC') ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: Text('Select Department'),
                      items: ['CSD', 'SEAS'].map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          _selectedSubCategory = null;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                  if (_selectedCollege == 'CAS') ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      hint: Text('Select Department'),
                      items: ['Natural Science', 'Medical Courses']
                          .map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          _selectedSubCategory = null;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                  // Subcategory Dropdown based on Department selection
                  if (_selectedDepartment != null) ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedSubCategory,
                      hint: Text('Select Subcategory'),
                      items: _getSubCategoryOptions().map((subCategory) {
                        return DropdownMenuItem(
                          value: subCategory,
                          child: Text(subCategory),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubCategory = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ],
                SizedBox(height: 10),
                TextFormField(
                  controller: _userIDController,
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a User ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _clubEmailController,
                  decoration: InputDecoration(
                    labelText: ' Email',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveToFirestore,
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getSubCategoryOptions() {
    if (_selectedCollege == 'CAS') {
      if (_selectedDepartment == 'Natural Science') {
        return ['Science Club', 'Math Club'];
      } else if (_selectedDepartment == 'Medical Courses') {
        return ['Sons', 'Phismets'];
      }
    } else if (_selectedCollege == 'CEAC') {
      if (_selectedDepartment == 'CSD') {
        return ['PSITS', 'BLIS'];
      } else if (_selectedDepartment == 'SEAS') {
        return ['PICE', 'ARCHI', 'EE', 'CompENG', 'ECE'];
      }
    } else if (_selectedCollege == 'CBA') {
      if (_selectedDepartment == 'Department of Business 1') {
        return ['Club E1', 'Club E2'];
      } else if (_selectedDepartment == 'Department of Administration 1') {
        return ['Club F1', 'Club F2'];
      }
    } else if (_selectedCollege == 'CED') {
      if (_selectedDepartment == 'Natural Science') {
        return ['Science', 'Math'];
      } else if (_selectedDepartment == 'RE') {
        return ['Club B1', 'Club B2'];
      }
    }
    return [];
  }
}
