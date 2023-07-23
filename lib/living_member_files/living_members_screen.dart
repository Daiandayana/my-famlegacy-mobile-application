import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/living_member_files/databases/living_members_db.dart';
import 'package:my_famlegacy/screens/drawers/creator_drawer.dart';

import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';

class ListFamLegacyMembers extends StatefulWidget {
  final String userID;
  const ListFamLegacyMembers({
    super.key,
    required this.userID,
  });

  @override
  State<ListFamLegacyMembers> createState() => _ListFamLegacyMembersState();
}

class _ListFamLegacyMembersState extends State<ListFamLegacyMembers> {
  CreatorDB? _cSnapshot;
  String famLegacyID = '';

  @override
  void initState() {
    super.initState();
    _fetchCreatorData();
  }

  Future<void> _fetchCreatorData() async {
    CreatorDB? cSnapshot = await getCreatorData(widget.userID);
    setState(() {
      _cSnapshot = cSnapshot;
      if (_cSnapshot != null) {
        famLegacyID = _cSnapshot!.famLegacyID;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CreatorDrawer(
        userID: widget.userID,
      ),
      appBar: AppBar(
        title: const Text('Manage Living Members'),
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
      body: _cSnapshot != null
          ? StreamBuilder<List<LivingMemberDB>>(
              stream: readListOfFamLegacyMembers(famLegacyID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final listFamLegacyMemberDB = snapshot.data!;

                  return ListView.builder(
                      itemCount: listFamLegacyMemberDB.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: 5.0, left: 5.0, top: 5.0),
                          child: Card(
                            elevation: 2,
                            child: ListTile(
                              tileColor:
                                  listFamLegacyMemberDB[index].requestStatus
                                      ? Colors.grey
                                      : Colors.white,
                              title: Text(listFamLegacyMemberDB[index].name),
                              subtitle: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Member Role : ${listFamLegacyMemberDB[index].memberRole}'),
                                  const Spacer(),
                                  _buildTrailingWidget(
                                      listFamLegacyMemberDB[index]),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: Text('No members found.'),
                  );
                }
              })
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildTrailingWidget(LivingMemberDB listFamLegacyMemberDB) {
    if (listFamLegacyMemberDB.memberRole == 'Creator') {
      return const Text('Cannot Change this Role');
    } else if (listFamLegacyMemberDB.memberRole == 'High Member') {
      return ElevatedButton(
        onPressed: () {
          _revertMemberRole(listFamLegacyMemberDB);
        },
        child: const Text('Revert back to Low Member'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          _promotedMemberRole(listFamLegacyMemberDB);
        },
        child: const Text('Promoted to High Member'),
      );
    }
  }

  Future _revertMemberRole(LivingMemberDB listFamLegacyMemberDB) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to revert the role for ${listFamLegacyMemberDB.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Revert'),
              onPressed: () {
                Navigator.of(context).pop();
                updateFamLegacyMemberRole(_cSnapshot!.famLegacyID,
                    listFamLegacyMemberDB.id, 'Low Member', false);
              },
            ),
          ],
        );
      },
    );
  }

  Future _promotedMemberRole(LivingMemberDB listFamLegacyMemberDB) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure you want to promoted the role for ${listFamLegacyMemberDB.name}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Promoted'),
              onPressed: () {
                Navigator.of(context).pop();
                updateFamLegacyMemberRole(
                  _cSnapshot!.famLegacyID,
                  listFamLegacyMemberDB.id,
                  'High Member',
                  false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
