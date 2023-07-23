import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/screens/drawers/creator_drawer.dart';
import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/registration/edit_user_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class CreatorHomeScreen extends StatefulWidget {
  final String userID;

  const CreatorHomeScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  CreatorDB? _cSnapshot;
  final double _heightSize = 34;

  @override
  void initState() {
    super.initState();
    _fetchCreatorData();
  }

  Future<void> _fetchCreatorData() async {
    CreatorDB? cSnapshot = await getCreatorData(widget.userID);

    setState(() {
      if (cSnapshot != null) {
        _cSnapshot = cSnapshot;
      }
    });
  }

  Future<void> _updateCreatorDetails() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserDetailsScreen(
          userID: widget.userID,
          name: _cSnapshot!.memberDetails['fullName'],
          phoneNum: _cSnapshot!.memberDetails['phoneNum'],
          address: _cSnapshot!.memberDetails['address'],
          birthDate: _cSnapshot!.memberDetails['birthDate'],
          birthOrder: _cSnapshot!.memberDetails['birthOrder'],
          isCreator: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CreatorDrawer(
          userID: widget.userID,
        ),
        appBar: AppBar(
          title: const Text('Creator Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log Out',
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LandingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: _cSnapshot != null
            ? ListView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                children: [
                    Column(
                      children: [
                        SizedBox(height: _heightSize),
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                          ),
                        ),
                        SizedBox(height: _heightSize),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _cSnapshot!.memberDetails['fullName'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _cSnapshot!.email,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Phone number',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _cSnapshot!.memberDetails['phoneNum'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Address',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _cSnapshot!.memberDetails['address'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Birth Order',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${_cSnapshot!.memberDetails['birthOrder']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Date of birth',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatTimestamp(
                                        _cSnapshot!.memberDetails['birthDate']),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            Row(
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Age',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${calculateAge(_cSnapshot!.memberDetails['birthDate'])}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: _heightSize),
                        const Text(
                          'Since you are a creator, your legacy named will be your own name.',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: _heightSize),
                        TextButton(
                          onPressed: _updateCreatorDetails,
                          child: const Text('Edit Details'),
                        ),
                      ],
                    ),
                  ])
            : const Center(child: CircularProgressIndicator()));
  }
}
