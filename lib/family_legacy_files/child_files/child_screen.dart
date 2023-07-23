import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/specific_member_screen.dart';
import 'package:my_famlegacy/family_legacy_files/child_files/databases/child_db.dart';
import 'package:my_famlegacy/family_legacy_files/child_files/functions/edit_child.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/family_legacy_files/grandchild_files/functions/create_grandchild.dart';
import 'package:my_famlegacy/family_legacy_files/grandchild_files/grandchild_screen.dart';

class ChildScreen extends StatefulWidget {
  final String userID,
      famLegacyID,
      grandparentID,
      parentID,
      parentName,
      parentSpouseName;
  final bool isEditable;

  const ChildScreen({
    Key? key,
    required this.userID,
    required this.famLegacyID,
    required this.grandparentID,
    required this.parentID,
    required this.parentName,
    required this.parentSpouseName,
    required this.isEditable,
  }) : super(key: key);

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
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
    return StreamBuilder<List<ChildDB>>(
      stream: readChildFromParent(
          widget.famLegacyID, widget.grandparentID, widget.parentID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final childDB = snapshot.data!;

          if (childDB.isEmpty) {
            return const Text('Married, No kid');
          }

          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: childDB.length,
              itemBuilder: (context, index) {
                final child = childDB[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Child Order : ${child.childBirthOrder}'),
                      Container(
                        color: Colors.grey,
                        child: Row(
                          children: [
                            const SizedBox(width: 10.0),
                            Expanded(
                              flex: 8,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(child.childName),
                                      const Spacer(),
                                      if (child.childStatus ==
                                              'Living Member' ||
                                          child.childStatus ==
                                              'Living Creator') ...[
                                        const Text(
                                          '[ A ]',
                                        ),
                                      ] else ...[
                                        const Text(
                                          '[ D ]',
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (child.marriage)
                                    Row(
                                      children: [
                                        Text(child.childSpouseName),
                                        const Spacer(),
                                        if (child.childSpouseStatus ==
                                                'Living Member' ||
                                            child.childSpouseStatus ==
                                                'Living Creator') ...[
                                          const Text(
                                            '[ A ]',
                                          ),
                                        ] else ...[
                                          const Text(
                                            '[ D ]',
                                          ),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (widget.isEditable)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => EditChild(
                                                    userID: widget.userID,
                                                    famLegacyID:
                                                        widget.famLegacyID,
                                                    grandparentID:
                                                        widget.grandparentID,
                                                    parentID: widget.parentID,
                                                    childID: child.childID,
                                                    parentName:
                                                        widget.parentName,
                                                    parentSpouseName:
                                                        widget.parentSpouseName,
                                                    selectedChildID:
                                                        child.childid,
                                                    selectedSpouseID:
                                                        child.childSpouseid)));
                                      } else if (value == 'create') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateGrandchild(
                                                        userID: widget.userID,
                                                        famLegacyID:
                                                            widget.famLegacyID,
                                                        grandparentID: widget
                                                            .grandparentID,
                                                        parentID:
                                                            widget.parentID,
                                                        childID: child.childID,
                                                        childName:
                                                            child.childName,
                                                        childSpouseName: child
                                                            .childSpouseName)));
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Are you sure you want to delete ${child.childName}?'),
                                              content: child.marriage
                                                  ? Text(
                                                      'and ${child.childSpouseName} will be deleted and cannot be undone once deleted.')
                                                  : const Text(
                                                      'will be deleted and cannot be undone once deleted.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                      'Don\'t Delete'),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      deleteChildFromParent(
                                                          widget.famLegacyID,
                                                          widget.grandparentID,
                                                          widget.parentID,
                                                          child.childID);
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyFamilyLegacyScreen(
                                                                      userID: widget
                                                                          .userID)));
                                                    },
                                                    child: const Text(
                                                        'Confirm Delete'))
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text('Edit Child'),
                                        ),
                                        if (child.marriage)
                                          const PopupMenuItem<String>(
                                            value: 'create',
                                            child: Text('Add Grandchild'),
                                          ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete Child'),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              )
                            else if (widget.isEditable == false)
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String value) {
                                      if (value == 'checkChild') {
                                        _checkProfile(child.childid);
                                      } else if (value == 'checkSpouse') {
                                        _checkProfile(child.childSpouseid);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: 'checkChild',
                                          child: Text('Check Child'),
                                        ),
                                        if (child.marriage == true)
                                          const PopupMenuItem<String>(
                                            value: 'checkSpouse',
                                            child: Text('Check Spouse'),
                                          ),
                                      ];
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      child.marriage == true
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Grandchild'),
                                  GrandChildScreen(
                                      userID: widget.userID,
                                      famLegacyID: widget.famLegacyID,
                                      grandparentID: widget.grandparentID,
                                      parentID: widget.parentID,
                                      childID: child.childID,
                                      isEditable: widget.isEditable),
                                ],
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(left: 10.0, top: 5.0),
                              child: Text('Not marriage yet')),
                    ],
                  ),
                );
              });
        } else {
          return const Center(
            child: Text('No children data found.'),
          );
        }
      },
    );
  }
}
