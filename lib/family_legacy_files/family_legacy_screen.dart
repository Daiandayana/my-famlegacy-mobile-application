// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/family_legacy_files/grandparent_files/grandparent_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import '../screens/drawers/creator_drawer.dart';
import '../screens/drawers/member_drawer.dart';
import 'grandparent_files/functions/create_grandparent.dart';
import '../screens/landing_screen.dart';

class MyFamilyLegacyScreen extends StatefulWidget {
  final String userID;
  const MyFamilyLegacyScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<MyFamilyLegacyScreen> createState() => _MyFamilyLegacyScreenState();
}

class _MyFamilyLegacyScreenState extends State<MyFamilyLegacyScreen> {
  CreatorDB? _cSnapshot;
  MemberDB? _mSnapshot;
  String _famLegacyID = '';
  bool isCreator = false;
  String _memberRole = '';
  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  void togglePopupMenu() {
    setState(() {
      isEditable = !isEditable;
    });
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.userID);
      MemberDB? mSnapshot = await getMemberData(widget.userID);

      if (cSnapshot != null) {
        _famLegacyID = cSnapshot.famLegacyID;
        isCreator = true;
      } else if (mSnapshot != null) {
        _famLegacyID = mSnapshot.legacyDetails['famLegacyID'];
        _memberRole = mSnapshot.memberRole;
      }

      setState(() {
        _cSnapshot = cSnapshot;
        _mSnapshot = mSnapshot;
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isCreator == false
          ? MemberDrawer(
              userID: widget.userID,
            )
          : CreatorDrawer(
              userID: widget.userID,
            ),
      appBar: AppBar(
        title: const Text('My Family Legacies'),
        actions: [
          if (_memberRole == 'High Member' || isCreator == true) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: togglePopupMenu,
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt),
              tooltip: 'Create Grandparent',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGrandparentScreen(
                      userID: widget.userID,
                      famLegacyID: _famLegacyID,
                    ),
                  ),
                );
              },
            ),
          ],
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
      body: _cSnapshot != null || _mSnapshot != null
          ? ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return GrandparentScreen(
                  isEditable: isEditable,
                  userID: widget.userID,
                  famLegacyID: _famLegacyID,
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
