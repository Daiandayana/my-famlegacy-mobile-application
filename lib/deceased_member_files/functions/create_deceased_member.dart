// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_famlegacy/deceased_member_files/databases/deceased_members_db.dart';
import 'package:my_famlegacy/deceased_member_files/deceased_member_screen.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';

class CreateDeceasedMember extends StatefulWidget {
  final String userID, famLegacyID, userName;

  const CreateDeceasedMember({
    super.key,
    required this.userID,
    required this.famLegacyID,
    required this.userName,
  });

  @override
  State<CreateDeceasedMember> createState() => _CreateDeceasedMemberState();
}

class _CreateDeceasedMemberState extends State<CreateDeceasedMember> {
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

  Future<void> _createDeceasedMember() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text.trim();
        int birthOrder = int.parse(_birthOrderController.text.trim());

        String dateOfBirthString = _birthDateController.text.trim();
        DateTime dateOfBirth = DateTime.parse(dateOfBirthString);
        Timestamp birthDate = Timestamp.fromDate(dateOfBirth);

        String dateOfdeathString = _deathDateController.text.trim();
        DateTime dateOfdeath = DateTime.parse(dateOfdeathString);
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

        bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(widget.userName),
              content: const Text(
                'Are you responsible to create this deceased member?\n\n'
                'Your name will be displayed as the user who created this deceased member.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Not confirmed
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirmed
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          await createNaturalDeceasedMember(
            widget.famLegacyID,
            name,
            birthOrder,
            birthDate,
            deathDate,
            widget.userName,
          );

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Create successful',
                object: 'Deceased Member successfully created',
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
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertBox(
              type: 'Create failed',
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
        title: const Text('Create Deceased Member'),
        centerTitle: true,
      ),
      body: Form(
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
                        DateFormat('yyyy-MM-dd').format(selectedDate);
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
                        DateFormat('yyyy-MM-dd').format(selectedDate);
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
                onPressed: _createDeceasedMember,
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
    );
  }
}
