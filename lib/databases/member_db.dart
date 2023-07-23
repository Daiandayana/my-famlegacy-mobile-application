// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_role_db.dart';

class MemberDB {
  final String id;
  final String email;
  final String memberRole;
  final Map<String, dynamic> memberDetails;
  final Map<String, dynamic> legacyDetails;

  MemberDB({
    required this.id,
    required this.email,
    required this.memberRole,
    required this.memberDetails,
    required this.legacyDetails,
  });
}

Future deleteMemberDB(String memberID) async {
  try {
    await FirebaseFirestore.instance
        .collection('Members')
        .doc(memberID)
        .delete();
    print('Success delete member account');
  } catch (error) {
    print('Error delete member: $error');
  }
}

Future registerMemberDB(
  String id,
  String email,
  String memberRole,
  Map<String, dynamic> memberDetails,
  Map<String, dynamic> legacyDetails,
) async {
  await FirebaseFirestore.instance.collection('Members').doc(id).set({
    'id': id,
    'email': email,
    'memberRole': memberRole,
    'memberDetails': memberDetails,
    'legacyDetails': legacyDetails,
  }).then((_) {
    print('Successfully store Member details into database');
  }).catchError((e) {
    print('Failed to store Member details into database: $e');
  });
}

Future registerMember(
  String email,
  String password,
  String name,
  String phoneNum,
  int birthOrder,
  Timestamp birthDate,
  String address,
) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      MemberDB m = MemberDB(
          id: user.uid,
          email: email,
          memberRole: 'Low Member',
          memberDetails: {
            'fullName': name,
            'phoneNum': phoneNum,
            'birthDate': birthDate,
            'birthOrder': birthOrder,
            'address': address,
          },
          legacyDetails: {
            'famLegacyID': '',
            'creatorName': '',
            'requestLegacy': false,
            'joinedLegacy': false,
          });

      registerMemberDB(
        m.id,
        m.email,
        m.memberRole,
        m.memberDetails,
        m.legacyDetails,
      );

      createUserRoleDB(m.email, m.id, 'Members');

      print('Successfully register Member !');
    }
  } catch (e) {
    print('Failed to register Member: $e');
  }
}

Future<MemberDB?> getMemberData(String id) async {
  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Members').doc(id).get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String email = snapshot['email'];
      String memberRole = snapshot['memberRole'];
      Map<String, dynamic> memberDetails = snapshot['memberDetails'];
      Map<String, dynamic> legacyDetails = snapshot['legacyDetails'];

      return MemberDB(
        id: id,
        email: email,
        memberRole: memberRole,
        memberDetails: memberDetails,
        legacyDetails: legacyDetails,
      );
    }
  } catch (e) {
    print('Failed to retrieve Member data: $e');
  }

  return null;
}

Future updateMemberDB(
  String id,
  String name,
  String phoneNum,
  Timestamp birthDate,
  int birthOrder,
  String address,
) async {
  await FirebaseFirestore.instance.collection('Members').doc(id).update({
    'memberDetails': {
      'fullName': name,
      'phoneNum': phoneNum,
      'birthOrder': birthOrder,
      'birthDate': birthDate,
      'address': address,
    },
  }).then((_) {
    print('Member details updated successfully!');
  }).catchError((error) {
    print('Failed to update student details: $error');
  });
}
