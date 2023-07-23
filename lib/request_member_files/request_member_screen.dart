// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/living_member_files/databases/living_members_db.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/request_member_files/databases/request_members_db.dart';
import 'package:my_famlegacy/screens/drawers/creator_drawer.dart';
import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class RequestMemberScreen extends StatefulWidget {
  final String userID;
  const RequestMemberScreen({
    super.key,
    required this.userID,
  });

  @override
  State<RequestMemberScreen> createState() => _RequestMemberScreenState();
}

class _RequestMemberScreenState extends State<RequestMemberScreen> {
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

  Future _acceptMember(String id) async {
    try {
      MemberDB? memberSnapshot = await getMemberData(id);

      if (memberSnapshot != null) {
        await createListOfMember(
          famLegacyID,
          memberSnapshot.id,
          memberSnapshot.memberDetails['fullName'],
          memberSnapshot.memberDetails['birthOrder'],
          memberSnapshot.memberDetails['birthDate'],
          'Low Member',
          false,
        );

        await updateRequestMember(
          famLegacyID,
          memberSnapshot.id,
          _cSnapshot!.memberDetails['fullName'],
          true,
          true,
        );

        await createListOfAllMember(
          famLegacyID,
          id,
          memberSnapshot.memberDetails['fullName'],
          memberSnapshot.memberDetails['birthOrder'],
          memberSnapshot.memberDetails['birthDate'],
          Timestamp.fromDate(DateTime(1900, 1, 1)),
          'Living Member',
        );

        deleteRequest(famLegacyID, id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Member data not found. Please try again.')),
        );
      }
    } catch (e) {
      print('Error accepting request: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error accepting request. Please try again.')),
      );
    }
  }

  Future _rejectMembers(String id) async {
    try {
      MemberDB? memberSnapshot = await getMemberData(id);

      await FirebaseFirestore.instance
          .collection('Legacies')
          .doc(famLegacyID)
          .collection('ListOfMemberRequest')
          .doc(id)
          .delete();

      updateRequestMember(
        '',
        memberSnapshot!.id,
        '',
        false,
        false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected successfully')),
      );
    } catch (error) {
      print('Error rejecting request: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error rejecting request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CreatorDrawer(
        userID: widget.userID,
      ),
      appBar: AppBar(
        title: const Text('Manage Request Members'),
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
          ? StreamBuilder<List<RequestFamLegacyMembers>>(
              stream: readRequestOfFamLegacyMembers(famLegacyID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final requestFamLegacyMembers = snapshot.data!;

                  return ListView.builder(
                      itemCount: requestFamLegacyMembers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: 5.0, left: 5.0, top: 5.0),
                          child: Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(requestFamLegacyMembers[index].name),
                              subtitle: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Email : ${requestFamLegacyMembers[index].email}'),
                                      Text(
                                          'Date Requested : ${formatTimestamp(requestFamLegacyMembers[index].dateRequested)}'),
                                    ],
                                  ),
                                  const Spacer(),
                                  _buildTrailingWidget(
                                      requestFamLegacyMembers[index]),
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

  Widget _buildTrailingWidget(RequestFamLegacyMembers requestFamLegacyMembers) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            _acceptMember(requestFamLegacyMembers.id);
          },
          child: const Text('Accept'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            _rejectMembers(requestFamLegacyMembers.id);
          },
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
