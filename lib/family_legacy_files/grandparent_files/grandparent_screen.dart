import 'package:flutter/material.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/family_legacy_files/grandparent_files/databases/grandparents_db.dart';
import 'package:my_famlegacy/family_legacy_files/grandparent_files/functions/create_grandparent.dart';
import 'package:my_famlegacy/family_legacy_files/grandparent_files/functions/edit_grandparent.dart';
import 'package:my_famlegacy/family_legacy_files/parent_files/functions/create_parent.dart';
import 'package:my_famlegacy/family_legacy_files/parent_files/parent_screen.dart';

class GrandparentScreen extends StatefulWidget {
  final String userID;
  final String famLegacyID;
  final bool isEditable;

  const GrandparentScreen({
    Key? key,
    required this.userID,
    required this.famLegacyID,
    required this.isEditable,
  }) : super(key: key);

  @override
  State<GrandparentScreen> createState() => _GrandparentScreenState();
}

class _GrandparentScreenState extends State<GrandparentScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GrandparentDB>>(
      stream: readGrandparent(widget.famLegacyID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final grandparentDB = snapshot.data!;

          if (widget.isEditable == false) {
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  SizedBox(height: 50.0),
                  Text('No Family Legacy create yet'),
                ],
              ),
            );
          }

          if (grandparentDB.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20.0),
                  const Center(
                      child: Text('No grandparent data found or create yet')),
                  const SizedBox(height: 20.0),
                  if (widget.isEditable == true)
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateGrandparentScreen(
                                userID: widget.userID,
                                famLegacyID: widget.famLegacyID,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                        ),
                        child: const Text('Create Family Legacy'))
                ],
              ),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: grandparentDB.length,
              itemBuilder: (context, index) {
                final grandparent = grandparentDB[index];

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grandparent Details :'),
                        Row(
                          children: [
                            Expanded(
                              flex: 8,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        grandparent.grandparentName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Text(
                                          'Birth Order: ${grandparent.grandparentBirthOrder}'),
                                      if (grandparent.grandparentStatus ==
                                              'Living Member' ||
                                          grandparent.grandparentStatus ==
                                              'Living Creator') ...[
                                        const Text(' [ A ]'),
                                      ] else ...[
                                        const Text(' [ D ]'),
                                      ],
                                    ],
                                  ),
                                  if (grandparent.marriage)
                                    Row(
                                      children: [
                                        Text(grandparent.grandparentSpouseName),
                                        const Spacer(),
                                        Text(
                                            'Birth Order: ${grandparent.grandparentSpouseBirthOrder}'),
                                        if (grandparent
                                                    .grandparentSpouseStatus ==
                                                'Living Member' ||
                                            grandparent
                                                    .grandparentSpouseStatus ==
                                                'Living Creator') ...[
                                          const Text(' [ A ]'),
                                        ] else ...[
                                          const Text(' [ D ]'),
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
                                                builder: (context) => EditGrandparent(
                                                    userID: widget.userID,
                                                    famLegacyID:
                                                        widget.famLegacyID,
                                                    grandparentID: grandparent
                                                        .grandparentID,
                                                    selectedGrandparentID:
                                                        grandparent
                                                            .grandparentid,
                                                    selectedSpouseID: grandparent
                                                        .grandparentSpouseid)));
                                      } else if (value == 'create') {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => CreateParent(
                                                    userID: widget.userID,
                                                    famLegacyID:
                                                        widget.famLegacyID,
                                                    grandparentID: grandparent
                                                        .grandparentID,
                                                    gFatherName: grandparent
                                                        .grandparentName,
                                                    gMotherName: grandparent
                                                        .grandparentSpouseName)));
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Are you sure you want to delete ${grandparent.grandparentName}?'),
                                              content: grandparent.marriage
                                                  ? Text(
                                                      'and ${grandparent.grandparentSpouseName} will be deleted and cannot be undone once deleted.')
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
                                                    deleteGrandParent(
                                                        widget.famLegacyID,
                                                        grandparent
                                                            .grandparentID);
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyFamilyLegacyScreen(
                                                                userID: widget
                                                                    .userID),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                      'Confirm Delete'),
                                                ),
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
                                          child: Text('Edit Grandparent'),
                                        ),
                                        if (grandparent.marriage)
                                          const PopupMenuItem<String>(
                                            value: 'create',
                                            child: Text('Add Parent'),
                                          ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete Grandparent'),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                flex: 1,
                                child: Container(),
                              )
                          ],
                        ),
                        grandparent.marriage
                            ? ParentScreen(
                                userID: widget.userID,
                                famLegacyID: widget.famLegacyID,
                                grandparentID: grandparent.grandparentID,
                                gFatherName: grandparent.grandparentName,
                                gMotherName: grandparent.grandparentSpouseName,
                                isEditable: widget.isEditable)
                            : const Padding(
                                padding: EdgeInsets.only(left: 10.0, top: 5.0),
                                child: Text('Married, No kids')),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } else {
          return const Center(
            child: Text('No grandparent data found.'),
          );
        }
      },
    );
  }
}
