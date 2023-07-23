// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/family_legacy_files/child_files/databases/child_db.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class CreateChild extends StatefulWidget {
  final String userID,
      famLegacyID,
      grandparentID,
      parentID,
      parentName,
      parentSpouseName;

  const CreateChild({
    super.key,
    required this.userID,
    required this.famLegacyID,
    required this.grandparentID,
    required this.parentID,
    required this.parentName,
    required this.parentSpouseName,
  });

  @override
  State<CreateChild> createState() => _CreateChildState();
}

class _CreateChildState extends State<CreateChild> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AllMemberDB? selectedChild;
  AllMemberDB? selectedSpouse;
  String selectedChildID = '';
  String selectedSpouseID = '';
  bool hasSpouse = true;
  final double _heightSize = 20;

  List<DropdownMenuItem<String>> _listOfChild(List<AllMemberDB> child) {
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
      selectedChild = child;
    });
  }

  Future<void> _fetchSelectedSpouseData(String id) async {
    final spouse = await getAllMemberData(widget.famLegacyID, id);
    setState(() {
      selectedSpouse = spouse;
    });
  }

  Future<void> _createChildAndSpouse() async {
    try {
      if (selectedChild != null) {
        if (hasSpouse && selectedSpouse != null) {
          await createChildFromParent(
              widget.famLegacyID,
              widget.grandparentID,
              widget.parentID,
              selectedChild!.id,
              selectedChild!.name,
              selectedChild!.status,
              selectedChild!.birthOrder,
              selectedChild!.id,
              selectedChild!.name,
              selectedChild!.status,
              true);
        } else {
          await createChildFromParent(
              widget.famLegacyID,
              widget.grandparentID,
              widget.parentID,
              selectedChild!.id,
              selectedChild!.name,
              selectedChild!.status,
              selectedChild!.birthOrder,
              '',
              'No Spouse',
              '',
              false);
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertBox(
              type: 'Add Child successful',
              object: 'Successfully add child',
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
            type: 'Failed to add child',
            object: 'Error: $e',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Create Family Legacy: Child')),
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
                    Text('Parent Name: ${widget.parentName}'),
                    SizedBox(height: _heightSize),
                    Text("Parent's Spouse Name: ${widget.parentSpouseName}"),
                    SizedBox(height: _heightSize),
                    DropdownButtonFormField<String>(
                      items: _listOfChild(allMember),
                      onChanged: (value) {
                        setState(() {
                          selectedChildID = value ?? '';
                          selectedChild = null;
                        });

                        if (selectedChildID.isNotEmpty) {
                          _fetchSelectedChildData(selectedChildID);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a child';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Select child for above parent:',
                      ),
                    ),
                    SizedBox(height: _heightSize),
                    if (selectedChild != null) ...[
                      const Text('Verify Details of the child:'),
                      SizedBox(height: _heightSize),
                      Text('Name: ${selectedChild!.name}'),
                      SizedBox(height: _heightSize),
                      Text('Birth Order: ${selectedChild!.birthOrder}'),
                      SizedBox(height: _heightSize),
                      if (selectedChild!.deathDate ==
                          Timestamp.fromDate(DateTime(1900, 1, 1))) ...[
                        Text(
                            'Birth Date: ${formatTimestamp(selectedChild!.birthDate)}'),
                        SizedBox(height: _heightSize),
                        const Text('Status: Alive'),
                      ] else ...[
                        Text(
                            'Birth Date: ${formatTimestamp(selectedChild!.birthDate)}'),
                        SizedBox(height: _heightSize),
                        Text(
                            'Death Date: ${formatTimestamp(selectedChild!.deathDate)}'),
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
                        labelText: 'Select spouse for this child:',
                      ),
                    ),
                    SizedBox(height: _heightSize),
                    if (selectedSpouse != null) ...[
                      const Text('Verify Details of the child:'),
                      SizedBox(height: _heightSize),
                      Text('Name: ${selectedSpouse!.name}'),
                      SizedBox(height: _heightSize),
                      Text('Birth Order: ${selectedSpouse!.birthOrder}'),
                      SizedBox(height: _heightSize),
                      if (selectedSpouse!.deathDate ==
                          Timestamp.fromDate(DateTime(1900, 1, 1))) ...[
                        Text(
                            'Birth Date: ${formatTimestamp(selectedSpouse!.birthDate)}'),
                        SizedBox(height: _heightSize),
                        const Text('Status: Alive'),
                      ] else ...[
                        Text(
                            'Birth Date: ${formatTimestamp(selectedSpouse!.birthDate)}'),
                        SizedBox(height: _heightSize),
                        Text(
                            'Death Date: ${formatTimestamp(selectedSpouse!.deathDate)}'),
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
                                      Text(
                                          'Are you sure you want to add this child slot?'),
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
                                      _createChildAndSpouse();
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
                      child: const Text('Add Child'),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
