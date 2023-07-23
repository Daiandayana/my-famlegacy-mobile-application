import 'package:flutter/material.dart';
import 'package:my_famlegacy/deceased_member_files/deceased_member_screen.dart';
import 'package:my_famlegacy/event_files/event_screen.dart';
import 'package:my_famlegacy/screens/member_screen/legacy_list_screen.dart';
import 'package:my_famlegacy/screens/member_home_screen.dart';
import 'package:my_famlegacy/screens/member_screen/request_role_screen.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/all_member_files/all_member_screen.dart';
import 'package:my_famlegacy/databases/member_db.dart';

class MemberDrawer extends StatefulWidget {
  final String userID;
  const MemberDrawer({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<MemberDrawer> createState() => _MemberDrawerState();
}

class _MemberDrawerState extends State<MemberDrawer> {
  MemberDB? _mSnapshot;
  String name = '', memberRole = '';
  bool joinedLegacy = false;

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future<void> _fetchMemberData() async {
    MemberDB? mSnapshot = await getMemberData(widget.userID);
    setState(() {
      _mSnapshot = mSnapshot;
      if (_mSnapshot != null) {
        memberRole = _mSnapshot!.memberRole;
        name = _mSnapshot!.memberDetails['fullName'];
        joinedLegacy = _mSnapshot!.legacyDetails['joinedLegacy'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _mSnapshot != null
        ? Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.lightBlue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Role: $memberRole',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Member Home'),
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemberHomeScreen(
                          userID: widget.userID,
                        ),
                      ),
                    );
                  },
                ),
                if (memberRole == 'Low Member' && joinedLegacy)
                  ListTile(
                    leading: const Icon(Icons.swap_horizontal_circle),
                    title: const Text('Request Member Role'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestRoleScreen(
                            userID: widget.userID,
                          ),
                        ),
                      );
                    },
                  ),
                if (joinedLegacy)
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('List of Family Members'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllOfMemberScreen(
                            userID: widget.userID,
                          ),
                        ),
                      );
                    },
                  ),
                if (joinedLegacy == false)
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: const Text('List of Existing Legacies'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LegacyListScreen(
                            userID: widget.userID,
                          ),
                        ),
                      );
                    },
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.family_restroom),
                    title: const Text('My Family Legacy'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyFamilyLegacyScreen(
                            userID: widget.userID,
                          ),
                        ),
                      );
                    },
                  ),
                if (memberRole == 'High Member')
                  ListTile(
                    leading: const Icon(Icons.person_remove),
                    title: const Text('Deceased Member'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListDeceasedMembersScreen(
                            userID: widget.userID,
                          ),
                        ),
                      );
                    },
                  ),
                if (joinedLegacy == true)
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Event Notification'),
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EventScreen(userID: widget.userID)),
                      );
                    },
                  ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
