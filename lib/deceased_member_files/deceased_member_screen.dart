// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/deceased_member_files/databases/deceased_members_db.dart';
import 'package:my_famlegacy/deceased_member_files/functions/create_deceased_member.dart';
import 'package:my_famlegacy/deceased_member_files/functions/edit_deceased_member.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';
import '../screens/drawers/creator_drawer.dart';
import '../screens/drawers/member_drawer.dart';
import '../screens/landing_screen.dart';

class ListDeceasedMembersScreen extends StatefulWidget {
  final String userID;
  const ListDeceasedMembersScreen({
    super.key,
    required this.userID,
  });

  @override
  State<ListDeceasedMembersScreen> createState() =>
      _ListDeceasedMembersScreenState();
}

class _ListDeceasedMembersScreenState extends State<ListDeceasedMembersScreen> {
  CreatorDB? _cSnapshot;
  MemberDB? _mSnapshot;
  String _famLegacyID = '', name = '', memberRole = '';
  bool isCreator = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.userID);
      MemberDB? mSnapshot = await getMemberData(widget.userID);

      if (cSnapshot != null) {
        _famLegacyID = cSnapshot.famLegacyID;
        name = cSnapshot.memberDetails['fullName'];
        isCreator = true;
      } else if (mSnapshot != null) {
        _famLegacyID = mSnapshot.legacyDetails['famLegacyID'];
        name = mSnapshot.memberDetails['fullName'];
        memberRole = mSnapshot.memberRole;
      }

      setState(() {
        _cSnapshot = cSnapshot;
        _mSnapshot = mSnapshot;
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  Future<void> _deleteDeceasedMember(
      String famLegacyID, String id, String name) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure to delete this Deceased Member ?'),
          content:
              Text('$name will be delete and cannot be undone once deleted'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Don\'t Delete'),
            ),
            TextButton(
              onPressed: () {
                deleteDeceasedMember(famLegacyID, id);
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirm Delete'),
            ),
          ],
        );
      },
    );
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
        title: const Text('Manage Deceased Members'),
        actions: [
          if (isCreator == true || memberRole == 'High Member')
            IconButton(
              icon: const Icon(Icons.person_add_alt),
              tooltip: 'Create Deceased Member',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateDeceasedMember(
                      userID: widget.userID,
                      famLegacyID: _famLegacyID,
                      userName: name,
                    ),
                  ),
                );
              },
            ),
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
          ? StreamBuilder<List<DeceasedMemberDB>>(
              stream: readListOfDeceasedMembers(_famLegacyID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final listDeceasedMemberDB = snapshot.data!;

                  return ListView.builder(
                      itemCount: listDeceasedMemberDB.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(listDeceasedMemberDB[index].name),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Birth Order : ${listDeceasedMemberDB[index].birthOrder}'),
                                Row(
                                  children: [
                                    Text(
                                      'From ${formatTimestamp(listDeceasedMemberDB[index].birthDate)} ',
                                    ),
                                    Text(
                                      'to ${formatTimestamp(listDeceasedMemberDB[index].deathDate)} ',
                                    ),
                                    Text(
                                        ' { ${calculateAgeWithDeath(listDeceasedMemberDB[index].birthDate, listDeceasedMemberDB[index].deathDate)} }'),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Created by: ${listDeceasedMemberDB[index].createBy}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: isCreator == true ||
                                    memberRole == 'High Member'
                                ? Container(
                                    padding: EdgeInsets.zero,
                                    child: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (String value) {
                                        if (value == 'edit') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditDeceasedMember(
                                                userID: widget.userID,
                                                memberID:
                                                    listDeceasedMemberDB[index]
                                                        .id,
                                                famLegacyID: _famLegacyID,
                                                name:
                                                    listDeceasedMemberDB[index]
                                                        .name,
                                                birthOrder:
                                                    listDeceasedMemberDB[index]
                                                        .birthOrder,
                                                birthDate:
                                                    listDeceasedMemberDB[index]
                                                        .birthDate,
                                                deathDate:
                                                    listDeceasedMemberDB[index]
                                                        .deathDate,
                                              ),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          _deleteDeceasedMember(
                                            _famLegacyID,
                                            listDeceasedMemberDB[index].id,
                                            listDeceasedMemberDB[index].name,
                                          );
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          const PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Text('Edit Details'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ];
                                      },
                                    ),
                                  )
                                : null,
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
}
