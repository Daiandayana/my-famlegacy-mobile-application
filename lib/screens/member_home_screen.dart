import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/screens/drawers/member_drawer.dart';
import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/registration/edit_user_screen.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/screens/member_screen/legacy_list_screen.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class MemberHomeScreen extends StatefulWidget {
  final String userID;

  const MemberHomeScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  MemberDB? _mSnapshot;
  final double _heightSize = 34;

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future<void> _fetchMemberData() async {
    MemberDB? mSnapshot = await getMemberData(widget.userID);
    setState(() {
      if (mSnapshot != null) {
        _mSnapshot = mSnapshot;
      }
    });
  }

  Future<void> _updateMemberDetails() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserDetailsScreen(
          userID: widget.userID,
          name: _mSnapshot!.memberDetails['fullName'],
          phoneNum: _mSnapshot!.memberDetails['phoneNum'],
          address: _mSnapshot!.memberDetails['address'],
          birthDate: _mSnapshot!.memberDetails['birthDate'],
          birthOrder: _mSnapshot!.memberDetails['birthOrder'],
          isCreator: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MemberDrawer(
          userID: widget.userID,
        ),
        appBar: AppBar(
          title: const Text('Member Home Screen'),
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
        body: _mSnapshot != null
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
                                    _mSnapshot!.memberDetails['fullName'],
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
                                    _mSnapshot!.email,
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
                                    _mSnapshot!.memberDetails['phoneNum'],
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
                                    _mSnapshot!.memberDetails['address'],
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
                                    '${_mSnapshot!.memberDetails['birthOrder']}',
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
                                        _mSnapshot!.memberDetails['birthDate']),
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
                                    '${calculateAge(_mSnapshot!.memberDetails['birthDate'])}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _heightSize),
                            TextButton(
                              onPressed: _updateMemberDetails,
                              child: const Text('Edit Details'),
                            ),
                            SizedBox(height: _heightSize),
                            Column(
                              children: [
                                _mSnapshot!.legacyDetails['requestLegacy'] &&
                                        _mSnapshot!
                                            .legacyDetails['joinedLegacy']
                                    ? Text(
                                        'You joined ${_mSnapshot!.legacyDetails['creatorName']} legacy')
                                    : _mSnapshot!.legacyDetails['requestLegacy']
                                        ? Text(
                                            'You have request to join ${_mSnapshot!.legacyDetails['creatorName']} legacy')
                                        : Column(
                                            children: [
                                              const Text(
                                                  'You have yet to joined any legacy'),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LegacyListScreen(
                                                          userID: widget.userID,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                      'Seach Legacy'))
                                            ],
                                          ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ])
            : const Center(child: CircularProgressIndicator()));
  }
}
