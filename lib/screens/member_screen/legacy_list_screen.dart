// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/request_member_files/databases/request_members_db.dart';
import 'package:my_famlegacy/screens/drawers/member_drawer.dart';
import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/databases/family_legacy_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class LegacyListScreen extends StatefulWidget {
  final String userID;
  const LegacyListScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<LegacyListScreen> createState() => _LegacyListScreenState();
}

class _LegacyListScreenState extends State<LegacyListScreen> {
  MemberDB? _mSnapshot;
  bool _requestLegacy = false;
  String _creatorName = '';
  RequestFamLegacyMembers? _requestFamLegacyMembers;
  String _famLegacyID = '';

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future _fetchMemberData() async {
    String famLegacyID = '';
    MemberDB? mSnapshot = await getMemberData(widget.userID);

    setState(() {
      _mSnapshot = mSnapshot;
      if (_mSnapshot != null) {
        _requestLegacy = _mSnapshot!.legacyDetails['requestLegacy'];
        _creatorName = _mSnapshot!.legacyDetails['creatorName'];
        famLegacyID = _mSnapshot!.legacyDetails['famLegacyID'];
      }

      _famLegacyID = famLegacyID;
      _fetchdateRequested();
    });
  }

  Future _fetchdateRequested() async {
    RequestFamLegacyMembers? requestFamLegacyMembers =
        await getNewMemberRequestData(_famLegacyID, widget.userID);
    setState(() {
      _requestFamLegacyMembers = requestFamLegacyMembers;
    });
  }

  Future<void> _joinLegacy(String creatorName, String famLegacyID) async {
    try {
      final parentContext = context;

      showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
          title: Text('Join $creatorName legacy'),
          content: const Text(
            'Are you sure you want to join ? Once you have joined the legacy, after being rejected by the creator,then you may join other legacies.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await createRequestFamLegacyMember(
                  famLegacyID,
                  _mSnapshot!.id,
                  _mSnapshot!.memberDetails['fullName'],
                  _mSnapshot!.email,
                );

                await updateRequestMember(
                  famLegacyID,
                  _mSnapshot!.id,
                  creatorName,
                  true,
                  false,
                );

                showDialog(
                  context: parentContext, // Use the stored parent context
                  builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text(
                      'You have successfully requested this legacy.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushAndRemoveUntil(
                            parentContext, // Use the stored parent context
                            MaterialPageRoute(
                              builder: (context) => LegacyListScreen(
                                userID: widget.userID,
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Join'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Failed to join legacy: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to join legacy. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MemberDrawer(
        userID: widget.userID,
      ),
      appBar: AppBar(
        title: const Text('List of Legacies'),
        centerTitle: true,
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
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<FamLegacyDB>>(
        stream: readListOfFamLegacy(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final famLegacyList = snapshot.data!;

            return _mSnapshot != null
                ? _requestLegacy == false
                    ? Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            child: const Text(
                              'Only the existing family legacy will appear, You may request to join any of them but only one request at a time is available',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: famLegacyList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 5.0, left: 5.0, top: 5.0),
                                  child: Card(
                                    elevation: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        _joinLegacy(
                                          famLegacyList[index].creatorName,
                                          famLegacyList[index].famLegacyID,
                                        );
                                      },
                                      child: ListTile(
                                        title: Text(
                                            famLegacyList[index].creatorName),
                                        subtitle: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Creator Email: ${famLegacyList[index].creatorEmail}'),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  const Text(
                                                    'Date created: ',
                                                  ),
                                                  Text(formatTimestamp(
                                                      famLegacyList[index]
                                                          .dateCreate))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : _requestFamLegacyMembers?.dateRequested != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'You have requested legacy from creator :',
                                ),
                                Text(
                                  _creatorName,
                                ),
                                Text(
                                  formatTimestamp(
                                      _requestFamLegacyMembers!.dateRequested),
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator(),
                          )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
