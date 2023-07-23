// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/living_member_files/databases/living_members_db.dart';
import 'package:my_famlegacy/screens/drawers/member_drawer.dart';
import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/databases/member_db.dart';

class RequestRoleScreen extends StatefulWidget {
  final String userID;
  const RequestRoleScreen({
    super.key,
    required this.userID,
  });

  @override
  State<RequestRoleScreen> createState() => _RequestRoleScreenState();
}

class _RequestRoleScreenState extends State<RequestRoleScreen> {
  MemberDB? _mSnapshot;
  LivingMemberDB? _famLegacyMemSnapshot;
  String famLegacyID = '';
  bool requestStatus = false;

  @override
  void initState() {
    super.initState();
    _fetchFamLegacyMemberData();
  }

  Future _fetchFamLegacyMemberData() async {
    try {
      MemberDB? memberSnapshot = await getMemberData(widget.userID);
      LivingMemberDB? famLegacyMemSnapshot;

      if (memberSnapshot != null) {
        famLegacyID = memberSnapshot.legacyDetails['famLegacyID'];
        famLegacyMemSnapshot =
            await getMemberRoleRequestData(famLegacyID, widget.userID);
      }

      setState(() {
        _mSnapshot = memberSnapshot;
        _famLegacyMemSnapshot = famLegacyMemSnapshot;
        requestStatus = _famLegacyMemSnapshot!.requestStatus;
      });
    } catch (error) {
      print('Failed to fetch member data: $error');
    }
  }

  Future<void> _requestRole() async {
    updateMemberRoleRequestStatus(famLegacyID, widget.userID, true);
    _fetchFamLegacyMemberData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MemberDrawer(
        userID: widget.userID,
      ),
      appBar: AppBar(
        title: const Text('Request Role'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LandingScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _mSnapshot != null
          ? requestStatus == false
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                          'Do you want to request High Member position from Creator?'),
                      ElevatedButton(
                        onPressed: _requestRole,
                        child: const Text('Request Role'),
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                      'Your have request the role, only wait for creator to change'),
                )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
