// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'package:my_famlegacy/screens/creator_home_screen.dart';
import 'package:my_famlegacy/screens/member_home_screen.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/widgets/alert_box.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class EditUserDetailsScreen extends StatefulWidget {
  final String userID, name, phoneNum, address;
  final Timestamp birthDate;
  final int birthOrder;
  final bool isCreator;

  const EditUserDetailsScreen({
    Key? key,
    required this.userID,
    required this.name,
    required this.phoneNum,
    required this.address,
    required this.birthDate,
    required this.birthOrder,
    required this.isCreator,
  }) : super(key: key);

  @override
  State<EditUserDetailsScreen> createState() => _EditUserDetailsScreenState();
}

class _EditUserDetailsScreenState extends State<EditUserDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthOrderController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  CreatorDB? _cSnapshot;
  MemberDB? _mSnapshot;
  String _famLegacyID = '';
  double heightSize = 38;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _nameController.text = widget.name;
    _birthDateController.text = formatTimestamp(widget.birthDate);
    _birthOrderController.text = widget.birthOrder.toString();
    _phoneNumController.text = widget.phoneNum;
    _addressController.text = widget.address;
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.userID);
      MemberDB? mSnapshot = await getMemberData(widget.userID);

      setState(() {
        _cSnapshot = cSnapshot;
        _mSnapshot = mSnapshot;
        if (_cSnapshot != null) {
          _famLegacyID = _cSnapshot!.famLegacyID;
        } else if (mSnapshot != null) {
          _famLegacyID = _mSnapshot!.legacyDetails['famLegacyID'];
        }
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text.trim();
        int birthOrder = int.parse(_birthOrderController.text.trim());
        String phoneNum = _phoneNumController.text.trim();
        String country = _addressController.text.trim();

        String dateOfBirthString = _birthDateController.text.trim();
        DateTime dateOfBirth =
            DateFormat('dd/MM/yyyy').parse(dateOfBirthString);
        Timestamp birthDate = Timestamp.fromDate(dateOfBirth);

        if (widget.isCreator == false) {
          await updateMemberDB(
            widget.userID,
            name,
            phoneNum,
            birthDate,
            birthOrder,
            country,
          );

          if (_mSnapshot!.legacyDetails['joinedLegacy'] == true &&
              _mSnapshot!.legacyDetails['requestLegacy'] == true) {
            await updateListOfAllMember(
              _famLegacyID,
              widget.userID,
              name,
              birthOrder,
              birthDate,
              Timestamp.fromDate(DateTime(1900, 1, 1)),
              'Living',
            );
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Update successful',
                object: 'Update member details success',
              );
            },
          ).then((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MemberHomeScreen(
                  userID: widget.userID,
                ),
              ),
              (route) => false,
            );
          });
        } else if (widget.isCreator == true) {
          await updateCreatorDB(
            widget.userID,
            name,
            phoneNum,
            birthDate,
            birthOrder,
            country,
          );

          await updateListOfAllMember(
            _famLegacyID,
            widget.userID,
            name,
            birthOrder,
            birthDate,
            Timestamp.fromDate(DateTime(1900, 1, 1)),
            'Living',
          );

          _nameController.clear();
          _birthDateController.clear();
          _birthOrderController.clear();
          _phoneNumController.clear();
          _addressController.clear();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertBox(
                type: 'Update successful',
                object: 'Update creator details success',
              );
            },
          ).then((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CreatorHomeScreen(
                  userID: widget.userID,
                ),
              ),
              (route) => false,
            );
          });
        }
      } catch (e) {
        print(e);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertBox(
              type: 'Update failed',
              object: 'Failed to update user. Please try again.',
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Details'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: heightSize),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Your full name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSize),
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
                  labelText: 'Your date of Birth',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a birth date';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSize),
              TextFormField(
                controller: _birthOrderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText:
                      'Your birth order in position among your siblings *number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a birth order';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSize),
              TextFormField(
                controller: _phoneNumController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Phone Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSize),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Country',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a country';
                  }
                  return null;
                },
              ),
              SizedBox(height: heightSize),
              ElevatedButton(
                onPressed: _updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
