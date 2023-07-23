// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/family_legacy_files/family_legacy_screen.dart';
import 'package:my_famlegacy/family_legacy_files/grandchild_files/databases/grandchild_db.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class CreateGrandchild extends StatefulWidget {
  final String userID,
      famLegacyID,
      grandparentID,
      parentID,
      childID,
      childName,
      childSpouseName;

  const CreateGrandchild({
    super.key,
    required this.userID,
    required this.famLegacyID,
    required this.grandparentID,
    required this.parentID,
    required this.childID,
    required this.childName,
    required this.childSpouseName,
  });

  @override
  State<CreateGrandchild> createState() => _CreateGrandchildState();
}

class _CreateGrandchildState extends State<CreateGrandchild> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AllMemberDB? selectedGrandchild;
  String selectedGrandchildID = '';
  final double _heightSize = 30;

  List<DropdownMenuItem<String>> _listOfGrandchild(List<AllMemberDB> members) {
    return members.map((member) {
      return DropdownMenuItem<String>(
        value: member.id,
        child: Text(member.name),
      );
    }).toList();
  }

  Future<void> _fetchSelectedgrandchildData(String id) async {
    final grandchild = await getAllMemberData(widget.famLegacyID, id);
    setState(() {
      selectedGrandchild = grandchild;
    });
  }

  Future _addGrandchildSlot() async {
    try {
      if (selectedGrandchild != null) {
        await createGrandchildFromChild(
          widget.famLegacyID,
          widget.grandparentID,
          widget.parentID,
          widget.childID,
          selectedGrandchild!.id,
          selectedGrandchild!.name,
          selectedGrandchild!.birthOrder,
          selectedGrandchild!.status,
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertBox(
              type: 'Successful',
              object: 'Successfully add grandchild',
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
      appBar: AppBar(
        title: const Text('Create Family Legacy: Grandchild'),
      ),
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
                  Text('Parent : ${widget.childName}'),
                  SizedBox(height: _heightSize),
                  Text('Spouse name : ${widget.childSpouseName}'),
                  SizedBox(height: _heightSize),
                  DropdownButtonFormField<String>(
                    items: _listOfGrandchild(allMember),
                    onChanged: (value) {
                      setState(() {
                        selectedGrandchildID = value ?? '';
                        selectedGrandchild = null;
                      });

                      if (selectedGrandchildID.isNotEmpty) {
                        _fetchSelectedgrandchildData(selectedGrandchildID);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a grandchild';
                      }
                      return null;
                    },
                    decoration:
                        const InputDecoration(labelText: 'Select grandchild :'),
                  ),
                  SizedBox(height: _heightSize),
                  if (selectedGrandchild != null) ...[
                    const Text('Verify Details of the child:'),
                    SizedBox(height: _heightSize),
                    Text('Name: ${selectedGrandchild!.name}'),
                    SizedBox(height: _heightSize),
                    Text('Birth Order: ${selectedGrandchild!.birthOrder}'),
                    SizedBox(height: _heightSize),
                    if (selectedGrandchild!.deathDate ==
                        Timestamp.fromDate(DateTime(1900, 1, 1))) ...[
                      Text(
                          'Birth Date: ${formatTimestamp(selectedGrandchild!.birthDate)}'),
                      SizedBox(height: _heightSize),
                      const Text('Status: Alive'),
                    ] else ...[
                      Text(
                          'Birth Date: ${formatTimestamp(selectedGrandchild!.birthDate)}'),
                      SizedBox(height: _heightSize),
                      Text(
                          'Death Date: ${formatTimestamp(selectedGrandchild!.deathDate)}'),
                      SizedBox(height: _heightSize),
                      const Text('Status: Deceased'),
                    ],
                    SizedBox(height: _heightSize),
                    ElevatedButton(
                      onPressed: () {
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
                                        'Are you sure you want to add this grandchild slot?'),
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
                                    if (_formKey.currentState!.validate()) {
                                      _addGrandchildSlot();
                                    }
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                      ),
                      child: const Text('Create grandchild'),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
