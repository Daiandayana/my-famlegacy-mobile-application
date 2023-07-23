import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/specific_member_screen.dart';
import 'package:my_famlegacy/family_legacy_files/child_files/child_screen.dart';
import 'package:my_famlegacy/family_legacy_files/child_files/functions/create_child.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'databases/parents_db.dart';
import 'functions/edit_parent.dart';

class ParentScreen extends StatefulWidget {
  final String userID, famLegacyID, grandparentID, gFatherName, gMotherName;

  final bool isEditable;

  const ParentScreen({
    Key? key,
    required this.userID,
    required this.famLegacyID,
    required this.grandparentID,
    required this.gFatherName,
    required this.gMotherName,
    required this.isEditable,
  }) : super(key: key);

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
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
    return StreamBuilder<List<ParentDB>>(
      stream:
          readParentFromGrandparent(widget.famLegacyID, widget.grandparentID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final parentDB = snapshot.data!;

          if (parentDB.isEmpty) {
            return const Text('Married, No kids');
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: parentDB.length,
            itemBuilder: (context, index) {
              final parent = parentDB[index];

              return Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parent Order : ${parent.parentBirthOrder}'),
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
                                    Text(parent.parentName),
                                    const Spacer(),
                                    if (parent.parentStatus ==
                                            'Living Member' ||
                                        parent.parentStatus ==
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
                                if (parent.marriage)
                                  Row(
                                    children: [
                                      Text(parent.parentSpouseName),
                                      const Spacer(),
                                      if (parent.parentSpouseStatus ==
                                              'Living Member' ||
                                          parent.parentSpouseStatus ==
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
                                              builder: (context) => EditParent(
                                                  userID: widget.userID,
                                                  famLegacyID:
                                                      widget.famLegacyID,
                                                  grandparentID:
                                                      widget.grandparentID,
                                                  parentID: parent.parentID,
                                                  gFatherName:
                                                      widget.gFatherName,
                                                  gMotherName:
                                                      widget.gMotherName,
                                                  selectedParentID:
                                                      parent.parentid,
                                                  selectedSpouseID:
                                                      parent.parentSpouseid)));
                                    } else if (value == 'create') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CreateChild(
                                                  userID: widget.userID,
                                                  famLegacyID:
                                                      widget.famLegacyID,
                                                  grandparentID:
                                                      widget.grandparentID,
                                                  parentID: parent.parentID,
                                                  parentName: parent.parentName,
                                                  parentSpouseName: parent
                                                      .parentSpouseName)));
                                    } else if (value == 'delete') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Are you sure you want to delete ${parent.parentName}?'),
                                            content: parent.marriage
                                                ? Text(
                                                    'and ${parent.parentSpouseName} will be deleted and cannot be undone once deleted.')
                                                : const Text(
                                                    'will be deleted and cannot be undone once deleted.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child:
                                                    const Text('Don\'t Delete'),
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    deleteParentFromGrandparent(
                                                        widget.famLegacyID,
                                                        widget.grandparentID,
                                                        parent.parentID);
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
                                        child: Text('Edit Parent'),
                                      ),
                                      if (parent.marriage)
                                        const PopupMenuItem<String>(
                                          value: 'create',
                                          child: Text('Add Child'),
                                        ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete Parent'),
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
                                    if (value == 'checkParent') {
                                      _checkProfile(parent.parentid);
                                    } else if (value == 'checkSpouse') {
                                      _checkProfile(parent.parentSpouseid);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'checkParent',
                                        child: Text('Check Parent'),
                                      ),
                                      if (parent.marriage == true)
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
                    parent.marriage
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, top: 5.0),
                            child: ChildScreen(
                                userID: widget.userID,
                                famLegacyID: widget.famLegacyID,
                                grandparentID: widget.grandparentID,
                                parentID: parent.parentID,
                                parentName: parent.parentName,
                                parentSpouseName: parent.parentSpouseName,
                                isEditable: widget.isEditable),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(left: 10.0, top: 5.0),
                            child: Text('Not marriage yet')),
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text('No parents data found.'),
          );
        }
      },
    );
  }
}
