// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import '../screens/landing_screen.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthOrderController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordVerificationController =
      TextEditingController();

  String _role = 'Member';
  double heightSize = 38;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    _birthOrderController.dispose();
    _phoneNumController.dispose();
    _addressController.dispose();
    _passwordVerificationController.dispose();

    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text.trim();
        String email = _emailController.text.trim();
        String password = _passwordController.text.trim();
        int birthOrder = int.parse(_birthOrderController.text.trim());
        String phoneNum = _phoneNumController.text.trim();
        String address = _addressController.text.trim();

        String dateOfBirthString = _birthDateController.text.trim();
        DateTime dateOfBirth = DateTime.parse(dateOfBirthString);
        Timestamp birthDate = Timestamp.fromDate(dateOfBirth);

        if (_role == 'Creator') {
          await registerCreator(
            email,
            password,
            name,
            phoneNum,
            birthOrder,
            birthDate,
            address,
          );
        } else {
          await registerMember(
            email,
            password,
            name,
            phoneNum,
            birthOrder,
            birthDate,
            address,
          );
        }

        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _birthDateController.clear();
        _birthOrderController.clear();
        _phoneNumController.clear();
        _addressController.clear();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertBox(
              type: 'Register successful',
              object: 'Congratulations! user successfully registered',
            );
          },
        ).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingScreen()),
          );
        });
      } catch (e) {
        String errorMessage = '$e';
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          errorMessage =
              'The email address is already in use by another account.';
        }
        print('Registration failed: $e');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertBox(
              type: 'Register failed',
              object: errorMessage,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register User Screen'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Do you want to be a creator?'),
                    const SizedBox(width: 20.0),
                    DropdownButton<String>(
                      value: _role,
                      onChanged: (newValue) {
                        setState(() {
                          _role = newValue!;
                        });
                      },
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Member',
                          child: Text('No'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Creator',
                          child: Text('Yes'),
                        ),
                      ].map((DropdownMenuItem<String> item) {
                        return DropdownMenuItem<String>(
                          value: item.value,
                          child: IntrinsicWidth(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: item.child,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 15.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    } else if (value.length < 7) {
                      return 'Password must be at least 7 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _passwordVerificationController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Verify Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the password again';
                    } else if (value != _passwordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _birthDateController,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                      setState(() {
                        _birthDateController.text = formattedDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Date of Birth',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date of birth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _birthOrderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Birth order among siblings',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a birth order';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _phoneNumController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Phone number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Full address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: heightSize),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text('Register'),
                ),
                SizedBox(height: heightSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
