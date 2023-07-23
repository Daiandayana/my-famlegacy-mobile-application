// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/family_legacy_files/grandparent_files/databases/grandparents_db.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class CreateGrandparentScreen extends StatefulWidget {
  final String userID, famLegacyID;

  const CreateGrandparentScreen({
    super.key,
    required this.userID,
    required this.famLegacyID,
  });

  @override
  State<CreateGrandparentScreen> createState() =>
      _CreateGrandparentScreenState();
}

class _CreateGrandparentScreenState extends State<CreateGrandparentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AllMemberDB? selectedParent;
  AllMemberDB? selectedSpouse;
  String selectedChildID = '';
  String selectedSpouseID = '';
  bool hasSpouse = true;
  final double _heightSize = 20;

  List<DropdownMenuItem<String>> _listOfGrandparent(List<AllMemberDB> child) {
    return child.map((childs) {
      return DropdownMenuItem<String>(
        value: childs.id,
        child: Text(childs.name),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _listOfSpouse(List<AllMemberDB> spouse) {
    List<DropdownMenuItem<String>> dropdownItems = [];

    dropdownItems.add(
      const DropdownMenuItem<String>(
        value: 'No spouse',
        child: Text('No spouse'),
      ),
    );

    dropdownItems.addAll(spouse.map((spouses) {
      return DropdownMenuItem<String>(
        value: spouses.id,
        child: Text(spouses.name),
      );
    }));

    return dropdownItems;
  }

  Future<void> _fetchSelectedChildData(String id) async {
    final child = await getAllMemberData(widget.famLegacyID, id);
    setState(() {
      selectedParent = child;
    });
  }

  Future<void> _fetchSelectedSpouseData(String id) async {
    final spouse = await getAllMemberData(widget.famLegacyID, id);
    setState(() {
      selectedSpouse = spouse;
    });
  }

  Future _createparentAndSpouse() async {
    try {
      if (selectedParent != null) {
        if (hasSpouse && selectedSpouse != null) {
          await createGrandparent(
              widget.famLegacyID,
              selectedParent!.id,
              selectedParent!.name,
              selectedParent!.status,
              selectedParent!.birthOrder,
              selectedSpouse!.id,
              selectedSpouse!.name,
              selectedSpouse!.status,
              selectedSpouse!.birthOrder,
              true);
        } else {
          await createGrandparent(
              widget.famLegacyID,
              selectedParent!.id,
              selectedParent!.name,
              selectedParent!.status,
              selectedParent!.birthOrder,
              '',
              'No Spouse',
              '',
              0,
              false);
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertBox(
              type: 'Add grandparent successful',
              object: 'Successfully add grandparent',
            );
          },
        ).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyFamilyLegacyScreen(userID: widget.userID),
            ),
          );
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertBox(
            type: 'Failed to add grandparent',
            object: 'Error: $e',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text('Create Family Legacies: Grandparent')),
        body: StreamBuilder<List<AllMemberDB>>(
          stream: readListOfAllMembers(widget.famLegacyID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allMember = snapshot.data!;

            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: _heightSize),
                    DropdownButtonFormField<String>(
                      items: _listOfGrandparent(allMember),
                      onChanged: (value) {
                        setState(() {
                          selectedChildID = value ?? '';
                          selectedParent = null;
                        });

                        if (selectedChildID.isNotEmpty) {
                          _fetchSelectedChildData(selectedChildID);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a grandparent';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select grandparent:',
                      ),
                    ),
                    SizedBox(height: _heightSize),
                    if (selectedParent != null) ...[
                      const Text(
                        'Verify Details of the grandparent:',
                      ),
                      SizedBox(height: _heightSize),
                      Text(
                        'Name: ${selectedParent!.name}',
                      ),
                      SizedBox(height: _heightSize),
                      Text(
                        'Birth Order: ${selectedParent!.birthOrder}',
                      ),
                      SizedBox(height: _heightSize),
                      if (selectedParent!.deathDate ==
                          Timestamp.fromDate(DateTime(1900, 1, 1))) ...[
                        Text(
                          'Birth Date: ${formatTimestamp(selectedParent!.birthDate)}',
                        ),
                        SizedBox(height: _heightSize),
                        const Text('Status: Alive'),
                      ] else ...[
                        Text(
                          'Birth Date: ${formatTimestamp(selectedParent!.birthDate)}',
                        ),
                        SizedBox(height: _heightSize),
                        Text(
                          'Death Date: ${formatTimestamp(selectedParent!.deathDate)}',
                        ),
                        SizedBox(height: _heightSize),
                        const Text('Status: Deceased'),
                      ],
                    ],
                    SizedBox(height: _heightSize),
                    DropdownButtonFormField<String>(
                      items: _listOfSpouse(allMember),
                      onChanged: (value) {
                        setState(() {
                          selectedSpouseID = value ?? '';
                          selectedSpouse = null;
                        });

                        if (selectedSpouseID.isNotEmpty) {
                          _fetchSelectedSpouseData(selectedSpouseID);
                        } else {
                          setState(() {
                            hasSpouse = false;
                          });
                        }
                      },
                      validator: (value) {
                        if (hasSpouse && (value == null || value.isEmpty)) {
                          return 'Please select a spouse';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select spouse for this grandparent:',
                      ),
                    ),
                    SizedBox(height: _heightSize),
                    if (selectedSpouse != null) ...[
                      const Text(
                        'Verify Details of the spouse:',
                      ),
                      SizedBox(height: _heightSize),
                      Text(
                        'Name: ${selectedSpouse!.name}',
                      ),
                      SizedBox(height: _heightSize),
                      Text(
                        'Birth Order: ${selectedSpouse!.birthOrder}',
                      ),
                      SizedBox(height: _heightSize),
                      if (selectedSpouse!.deathDate ==
                          Timestamp.fromDate(DateTime(1900, 1, 1))) ...[
                        Text(
                          'Birth Date: ${formatTimestamp(selectedSpouse!.birthDate)}',
                        ),
                        SizedBox(height: _heightSize),
                        const Text('Status: Alive'),
                      ] else ...[
                        Text(
                          'Birth Date: ${formatTimestamp(selectedSpouse!.birthDate)}',
                        ),
                        SizedBox(height: _heightSize),
                        Text(
                          'Death Date: ${formatTimestamp(selectedSpouse!.deathDate)}',
                        ),
                        SizedBox(height: _heightSize),
                        const Text('Status: Deceased'),
                      ],
                    ],
                    SizedBox(height: _heightSize),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmation'),
                                content: const SingleChildScrollView(
                                  child: ListBody(
                                    children: <Widget>[
                                      Text('Create grandparents ?'),
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
                                    onPressed: () {
                                      _createparentAndSpouse();
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                      ),
                      child: const Text('Add Grandparent'),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
