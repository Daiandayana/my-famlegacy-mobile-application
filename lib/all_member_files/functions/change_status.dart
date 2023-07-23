// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/databases/user_role_db.dart';
import 'package:my_famlegacy/deceased_member_files/databases/deceased_members_db.dart';
import 'package:my_famlegacy/deceased_member_files/deceased_member_screen.dart';
import 'package:my_famlegacy/living_member_files/databases/living_members_db.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class ChangeStatusLivingintoDeceased extends StatefulWidget {
  final String userID, memberID;

  const ChangeStatusLivingintoDeceased({
    Key? key,
    required this.userID,
    required this.memberID,
  }) : super(key: key);

  @override
  State<ChangeStatusLivingintoDeceased> createState() =>
      _ChangeStatusLivingintoDeceasedState();
}

class _ChangeStatusLivingintoDeceasedState
    extends State<ChangeStatusLivingintoDeceased> {
  MemberDB? _memberSnapshot;
  String _famLegacyID = '', _fullName = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _deathDateController = TextEditingController();
  double heightSize = 38;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  @override
  void dispose() {
    _deathDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.userID);
      MemberDB? uSnapshot = await getMemberData(widget.userID);
      MemberDB? mSnapshot = await getMemberData(widget.memberID);

      setState(() {
        if (uSnapshot != null && mSnapshot != null) {
          _fullName = uSnapshot.memberDetails['fullName'];
          _famLegacyID = uSnapshot.legacyDetails['famLegacyID'];
          _memberSnapshot = mSnapshot;
        } else if (cSnapshot != null && mSnapshot != null) {
          _fullName = cSnapshot.memberDetails['fullName'];
          _famLegacyID = cSnapshot.famLegacyID;
          _memberSnapshot = mSnapshot;
        }
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  Future<void> _changeStatusMember() async {
    if (_formKey.currentState!.validate()) {
      try {
        String dateOfdeathString = _deathDateController.text.trim();
        DateFormat format = DateFormat('dd/MM/yyyy');
        DateTime dateOfdeath = format.parse(dateOfdeathString);
        Timestamp deathDate = Timestamp.fromDate(dateOfdeath);

        Timestamp birthDate = _memberSnapshot!.memberDetails['birthDate'];

        if (dateOfdeath.isBefore(birthDate.toDate())) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Invalid Date'),
                content: const Text(
                    'The date of death cannot be before the date of birth.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(_memberSnapshot!.memberDetails['fullName']),
              content: const Text(
                'Are you responsible to create this deceased member?\n\n'
                'Your name will be displayed as the user who created this deceased member.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          await createChangeDeceasedMember(
            _famLegacyID,
            _memberSnapshot!.id,
            _memberSnapshot!.memberDetails['fullName'],
            _memberSnapshot!.memberDetails['birthOrder'],
            _memberSnapshot!.memberDetails['birthDate'],
            deathDate,
            _fullName,
          );

          await updateListOfAllMember(
            _famLegacyID,
            _memberSnapshot!.id,
            _memberSnapshot!.memberDetails['fullName'],
            _memberSnapshot!.memberDetails['birthOrder'],
            _memberSnapshot!.memberDetails['birthDate'],
            deathDate,
            'Deceased',
          );

          await deleteUserRole(_memberSnapshot!.email);

          await deleteLivingMembers(_famLegacyID, _memberSnapshot!.id);

          await deleteMemberDB(_memberSnapshot!.id);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Successfully Change member into deceased',
                object:
                    'Notice: please update My Family Legacy for this person',
              );
            },
          ).then((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ListDeceasedMembersScreen(
                  userID: widget.userID,
                ),
              ),
            );
          });
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertBox(
              type: 'Change Status failed',
              object: '$error',
            );
          },
        );

        print('Error changing this member');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Status into Deceased'),
        centerTitle: true,
      ),
      body: _memberSnapshot != null
          ? Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: heightSize),
                    const Text(
                      'The Details of the person who recently deceased',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Text(
                          'Name : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _memberSnapshot!.memberDetails['fullName'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Text(
                          'Email : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _memberSnapshot!.email,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Text(
                          'Phone Number : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _memberSnapshot!.memberDetails['phoneNum'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Text(
                          'Birth Date : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          formatTimestamp(
                              _memberSnapshot!.memberDetails['birthDate']),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Text(
                          'Birth Order : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_memberSnapshot!.memberDetails['birthOrder']}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    TextFormField(
                      controller: _deathDateController,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (selectedDate != null) {
                          String formattedDate =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                          setState(() {
                            _deathDateController.text = formattedDate;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'Date of death',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select date of death';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: heightSize),
                    ElevatedButton(
                      onPressed: _changeStatusMember,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
