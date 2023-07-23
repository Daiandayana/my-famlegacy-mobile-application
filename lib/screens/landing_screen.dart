// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/registration/register_user_screen.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'creator_home_screen.dart';
import 'member_home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          String email = userCredential.user!.email!;

          DocumentSnapshot roleSnapshot = await FirebaseFirestore.instance
              .collection('UserRoles')
              .doc(email)
              .get();

          if (roleSnapshot.exists) {
            String role = roleSnapshot.get('role');
            String userID = roleSnapshot.get('id');
            print(userID);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully Login')),
            );

            if (role == 'Creators') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CreatorHomeScreen(userID: userID),
                  maintainState: false,
                ),
              );
            } else if (role == 'Members') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MemberHomeScreen(userID: userID),
                  maintainState: false,
                ),
              );
            }

            _emailController.clear();
            _passwordController.clear();
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Please try again',
                object: 'Email is wrong or not found',
              );
            },
          );
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Please try again',
                object: 'Password is not match',
              );
            },
          );
        } else if (e.code == 'invalid-email') {
          print('The email address is improperly formatted.');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Please try again',
                object: 'Invalid email format',
              );
            },
          );
        }
      } catch (e) {
        print('Login Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background_image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
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
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15.0),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account yet?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 3.0),
                    TextButton(
                      onPressed: () {
                        _emailController.clear();
                        _passwordController.clear();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterUserScreen(),
                          ),
                        );
                      },
                      child: const Text('Register Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
