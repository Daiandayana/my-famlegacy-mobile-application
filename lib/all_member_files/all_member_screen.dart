// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/all_member_files/functions/change_status.dart';
import 'package:my_famlegacy/all_member_files/specific_member_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';
import '../screens/drawers/creator_drawer.dart';
import '../screens/drawers/member_drawer.dart';
import '../screens/landing_screen.dart';

class AllOfMemberScreen extends StatefulWidget {
  final String userID;
  const AllOfMemberScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<AllOfMemberScreen> createState() => _AllOfMemberScreenState();
}

class _AllOfMemberScreenState extends State<AllOfMemberScreen> {
  CreatorDB? _cSnapshot;
  MemberDB? _mSnapshot;
  String _famLegacyID = '', _memberRole = '';
  bool isCreator = false;
  String _sortBy = 'Birth Order Ascending';

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
        isCreator = true;
      } else if (mSnapshot != null) {
        _memberRole = mSnapshot.memberRole;
        _famLegacyID = mSnapshot.legacyDetails['famLegacyID'];
      }

      setState(() {
        _cSnapshot = cSnapshot;
        _mSnapshot = mSnapshot;
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  Future _checkProfile(AllMemberDB allMemberDB) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificMember(
          userID: widget.userID,
          famLegacyID: _famLegacyID,
          specificMemberID: allMemberDB.id,
        ),
      ),
    );
  }

  Future _changeStatus(AllMemberDB allMemberDB) async {
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
                  'Do you want to change ${allMemberDB.name} status into Deceased Member?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangeStatusLivingintoDeceased(
                      userID: widget.userID,
                      memberID: allMemberDB.id,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<AllMemberDB> _sortMembers(List<AllMemberDB> members, String sortBy) {
    switch (sortBy) {
      case 'Birth Order Ascending':
        members.sort((a, b) => a.birthOrder.compareTo(b.birthOrder));
        break;
      case 'Birth Order Descending':
        members.sort((a, b) => b.birthOrder.compareTo(a.birthOrder));
        break;
      case 'Birth Date Ascending':
        members.sort((a, b) => a.birthDate.compareTo(b.birthDate));
        break;
      case 'Birth Date Descending':
        members.sort((a, b) => b.birthDate.compareTo(a.birthDate));
        break;
      default:
        return members;
    }
    return members;
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
        title: const Text('Lists'),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (String? newValue) {
              setState(() {
                _sortBy = newValue!;
              });
            },
            items: const [
              DropdownMenuItem<String>(
                value: 'Birth Order Ascending',
                child: Text('Birth Order Ascending'),
              ),
              DropdownMenuItem<String>(
                value: 'Birth Order Descending',
                child: Text('Birth Order Descending'),
              ),
              DropdownMenuItem<String>(
                value: 'Birth Date Ascending',
                child: Text('Birth Date Ascending'),
              ),
              DropdownMenuItem<String>(
                value: 'Birth Date Descending',
                child: Text('Birth Date Descending'),
              ),
            ],
          ),
          const SizedBox(width: 10.0),
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
          ? StreamBuilder<List<AllMemberDB>>(
              stream: readListOfAllMembers(_famLegacyID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final listOfAllMembersDB = snapshot.data!;

                  return ListView.builder(
                    itemCount: listOfAllMembersDB.length,
                    itemBuilder: (context, index) {
                      final sortedMembers =
                          _sortMembers(listOfAllMembersDB, _sortBy);
                      final member = sortedMembers[index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(member.name),
                            ],
                          ),
                          subtitle: Row(children: [
                            _sortBy == 'Birth Order Ascending' ||
                                    _sortBy == 'Birth Order Descending'
                                ? Text('Birth Order: ${member.birthOrder}')
                                : Text(
                                    'Birth Date: ${formatTimestamp(member.birthDate)} / age: ${calculateAge(member.birthDate)}'),
                            const Spacer(),
                            member.status == 'Living Member' ||
                                    member.status == 'Living Creator'
                                ? const Text('Alive')
                                : const Text('Deceased'),
                          ]),
                          trailing:
                              listOfAllMembersDB[index].id == widget.userID
                                  ? const Text('This you')
                                  : Container(
                                      padding: EdgeInsets.zero,
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (String value) {
                                          if (value == 'deceased') {
                                            _changeStatus(
                                                listOfAllMembersDB[index]);
                                          } else if (value == 'checkProfile') {
                                            _checkProfile(
                                                listOfAllMembersDB[index]);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return [
                                            if (_memberRole == 'High Member' ||
                                                isCreator == true)
                                              if (listOfAllMembersDB[index]
                                                      .status ==
                                                  'Living Member')
                                                const PopupMenuItem<String>(
                                                  value: 'deceased',
                                                  child: Text(
                                                      'Change Status into Deceased'),
                                                ),
                                            const PopupMenuItem<String>(
                                              value: 'checkProfile',
                                              child: Text('Check Profile'),
                                            ),
                                          ];
                                        },
                                      ),
                                    ),
                        ),
                      );
                    },
                  );
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
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
