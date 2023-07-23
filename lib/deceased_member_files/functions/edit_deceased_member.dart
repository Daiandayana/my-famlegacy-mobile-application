// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/deceased_member_files/databases/deceased_members_db.dart';
import 'package:my_famlegacy/deceased_member_files/deceased_member_screen.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class EditDeceasedMember extends StatefulWidget {
  final String name, userID, memberID, famLegacyID;
  final int birthOrder;
  final Timestamp birthDate, deathDate;

  const EditDeceasedMember({
    super.key,
    required this.userID,
    required this.memberID,
    required this.famLegacyID,
    required this.name,
    required this.birthOrder,
    required this.birthDate,
    required this.deathDate,
  });

  @override
  State<EditDeceasedMember> createState() => _EditDeceasedMemberState();
}

class _EditDeceasedMemberState extends State<EditDeceasedMember> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthOrderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _deathDateController = TextEditingController();
  final double _heightSize = 38;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _birthOrderController.dispose();
    _deathDateController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _birthOrderController.text = widget.birthOrder.toString();
    _birthDateController.text = formatTimestamp(widget.birthDate);
    _deathDateController.text = formatTimestamp(widget.deathDate);
  }

  Future<void> _updateDeceasedMember() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text.trim();
        int birthOrder = int.parse(_birthOrderController.text.trim());

        String dateOfBirthString = _birthDateController.text.trim();
        DateTime dateOfBirth =
            DateFormat('dd/MM/yyyy').parse(dateOfBirthString);
        Timestamp birthDate = Timestamp.fromDate(dateOfBirth);

        String dateOfdeathString = _deathDateController.text.trim();
        DateTime dateOfdeath =
            DateFormat('dd/MM/yyyy').parse(dateOfdeathString);
        Timestamp deathDate = Timestamp.fromDate(dateOfdeath);

        if (dateOfdeath.isBefore(dateOfBirth)) {
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
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        await updateDeceasedMember(
          widget.famLegacyID,
          widget.memberID,
          name,
          birthOrder,
          birthDate,
          deathDate,
        );

        await updateListOfAllMember(
          widget.famLegacyID,
          widget.memberID,
          name,
          birthOrder,
          birthDate,
          deathDate,
          'Deceased',
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertBox(
              type: 'Update successful',
              object: 'Deceased Member details update success',
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

        _nameController.clear();
        _birthDateController.clear();
        _birthOrderController.clear();
        _deathDateController.clear();
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertBox(
              type: 'Update Deceased Member failed',
              object: '$error',
            );
          },
        );

        print('Error creating this Deceased Member');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Deceased Member Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: _heightSize),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'His/Her full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: _heightSize),
                TextFormField(
                  controller: _birthOrderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'His/Her birth order among his/her siblings',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a birth order';
                    }
                    return null;
                  },
                ),
                SizedBox(height: _heightSize),
                TextFormField(
                  controller: _birthDateController,
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
                        _birthDateController.text = formattedDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Date of birth',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select birth date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: _heightSize),
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
                SizedBox(height: _heightSize),
                ElevatedButton(
                  onPressed: _updateDeceasedMember,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
