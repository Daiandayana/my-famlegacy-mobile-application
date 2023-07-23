import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/specific_member_screen.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/family_legacy_files/grandchild_files/databases/grandchild_db.dart';

class GrandChildScreen extends StatefulWidget {
  final String userID, famLegacyID, grandparentID, parentID, childID;
  final bool isEditable;

  const GrandChildScreen({
    super.key,
    required this.userID,
    required this.famLegacyID,
    required this.grandparentID,
    required this.parentID,
    required this.childID,
    required this.isEditable,
  });

  @override
  State<GrandChildScreen> createState() => _GrandChildScreenState();
}

class _GrandChildScreenState extends State<GrandChildScreen> {
  Future _checkProfile(String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpecificMember(
          userID: widget.userID,
          famLegacyID: widget.famLegacyID,
          specificMemberID: id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GrandchildDB>>(
      stream: readGrandchildFromChild(widget.famLegacyID, widget.grandparentID,
          widget.parentID, widget.childID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final grandchildrenDB = snapshot.data!;

          if (grandchildrenDB.isEmpty) {
            return const Text('Married, No kid');
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grandchildrenDB.length,
            itemBuilder: (context, index) {
              final grandchild = grandchildrenDB[index];

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Row(
                        children: [
                          Text('{ ${grandchild.birthOrder} } '),
                          Text(grandchild.name),
                          const Spacer(),
                          if (grandchild.status == 'Living Member' ||
                              grandchild.status == 'Living Creator') ...[
                            const Text(' [ A ]'),
                          ] else ...[
                            const Text(' [ D ]'),
                          ],
                        ],
                      ),
                    ),
                    if (widget.isEditable == true)
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete this child ?'),
                                  content: const Text('Are you sure ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        deleteGrandchildFromChild(
                                            widget.famLegacyID,
                                            widget.grandparentID,
                                            widget.parentID,
                                            widget.childID,
                                            grandchild.grandchildID);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MyFamilyLegacyScreen(
                                                    userID: widget.userID),
                                          ),
                                        );
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      )
                    else if (widget.isEditable == false)
                      Expanded(
                        flex: 1,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (String value) {
                            if (value == 'checkgrandchild') {
                              _checkProfile(grandchild.id);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'checkgrandchild',
                                child: Text('Check Grandchild'),
                              ),
                            ];
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No grandchildren data found.'));
        }
      },
    );
  }
}
