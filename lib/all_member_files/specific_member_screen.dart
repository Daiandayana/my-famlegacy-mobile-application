// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/deceased_member_files/databases/deceased_members_db.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class SpecificMember extends StatefulWidget {
  final String userID, famLegacyID, specificMemberID;

  const SpecificMember({
    super.key,
    required this.userID,
    required this.famLegacyID,
    required this.specificMemberID,
  });

  @override
  State<SpecificMember> createState() => _SpecificMemberState();
}

class _SpecificMemberState extends State<SpecificMember> {
  CreatorDB? _cSnapshot;
  MemberDB? _mSnapshot;
  DeceasedMemberDB? _dSnapshot;
  String _fullName = '',
      _phoneNum = '',
      _address = '',
      _email = '',
      _createBy = '',
      _status = '';
  Timestamp _birthDate = Timestamp(0, 0), _deathDate = Timestamp(0, 0);
  int _birthOrder = 0;
  double heightSize = 38;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.specificMemberID);
      MemberDB? mSnapshot = await getMemberData(widget.specificMemberID);
      DeceasedMemberDB? dSnapshot = await getDeceasedMemberData(
          widget.famLegacyID, widget.specificMemberID);

      setState(() {
        if (cSnapshot != null) {
          _cSnapshot = cSnapshot;
          _email = cSnapshot.email;
          _fullName = cSnapshot.memberDetails['fullName'];
          _phoneNum = cSnapshot.memberDetails['phoneNum'];
          _address = cSnapshot.memberDetails['address'];
          _birthDate = cSnapshot.memberDetails['birthDate'];
          _birthOrder = cSnapshot.memberDetails['birthOrder'];
          _status = 'Living Member';
        } else if (mSnapshot != null) {
          _mSnapshot = mSnapshot;
          _email = mSnapshot.email;
          _fullName = mSnapshot.memberDetails['fullName'];
          _phoneNum = mSnapshot.memberDetails['phoneNum'];
          _address = mSnapshot.memberDetails['address'];
          _birthDate = mSnapshot.memberDetails['birthDate'];
          _birthOrder = mSnapshot.memberDetails['birthOrder'];
          _status = 'Living Member';
        } else if (dSnapshot != null) {
          _dSnapshot = dSnapshot;
          _deathDate = dSnapshot.deathDate;
          _fullName = dSnapshot.name;
          _birthDate = dSnapshot.birthDate;
          _birthOrder = dSnapshot.birthOrder;
          _createBy = dSnapshot.createBy;
          _status = 'Deceased Member';
        }
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _cSnapshot != null || _mSnapshot != null || _dSnapshot != null
        ? Scaffold(
            appBar: AppBar(
              title: Text('$_status Details'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  if (_cSnapshot != null || _mSnapshot != null) ...[
                    SizedBox(height: heightSize),
                    const Text(
                      'This is a living member details : ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Full name :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _fullName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Email :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _email,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Phone Number :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _phoneNum,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Birth in Order :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '$_birthOrder',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Date of Birth [ Age ] :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${formatTimestamp(_birthDate)} [ ${calculateAge(_birthDate)} ]',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Address :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _address,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                  ] else if (_dSnapshot != null) ...[
                    SizedBox(height: heightSize),
                    const Text(
                      'This is a deceased member details : ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Full name :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _fullName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Birth in Order :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '$_birthOrder',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Date of death [ Age ] :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${formatTimestamp(_deathDate)} [ ${calculateAgeWithDeath(_birthDate, _deathDate)} ]',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Date of Birth :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            formatTimestamp(_birthDate),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: heightSize),
                    Row(
                      children: [
                        const Expanded(
                            flex: 2,
                            child: Text(
                              'Create by :',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Text(
                            _createBy,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(title: const Text('Loading')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
