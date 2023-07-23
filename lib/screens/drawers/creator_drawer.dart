import 'package:flutter/material.dart';
import 'package:my_famlegacy/event_files/event_screen.dart';
import 'package:my_famlegacy/screens/creator_home_screen.dart';
import 'package:my_famlegacy/living_member_files/living_members_screen.dart';
import 'package:my_famlegacy/request_member_files/request_member_screen.dart';
import 'package:my_famlegacy/deceased_member_files/deceased_member_screen.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/all_member_files/all_member_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';

class CreatorDrawer extends StatefulWidget {
  final String userID;
  const CreatorDrawer({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<CreatorDrawer> createState() => _CreatorDrawerState();
}

class _CreatorDrawerState extends State<CreatorDrawer> {
  CreatorDB? _cSnapshot;
  String name = '';

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future<void> _fetchMemberData() async {
    CreatorDB? cSnapshot = await getCreatorData(widget.userID);
    setState(() {
      _cSnapshot = cSnapshot;
      if (_cSnapshot != null) {
        name = _cSnapshot!.memberDetails['fullName'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _cSnapshot != null
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
                      const Text(
                        'Role: Creator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Creator Home'),
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatorHomeScreen(
                          userID: widget.userID,
                        ),
                      ),
                    );
                  },
                ),
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
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('Manage Request Members'),
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestMemberScreen(
                          userID: widget.userID,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Manage Living Members'),
                  onTap: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListFamLegacyMembers(
                          userID: widget.userID,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_remove),
                  title: const Text('Manage Deceased Member'),
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
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
