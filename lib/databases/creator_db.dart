// ignore_for_file: avoid_print

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_famlegacy/living_member_files/databases/living_members_db.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';
import 'family_legacy_db.dart';
import 'user_role_db.dart';

class CreatorDB {
  final String id;
  final String email;
  final String famLegacyID;
  final Map<String, dynamic> memberDetails;

  CreatorDB({
    required this.id,
    required this.email,
    required this.famLegacyID,
    required this.memberDetails,
  });
}

Future updateCreatorDB(
  String id,
  String name,
  String phoneNum,
  Timestamp birthDate,
  int birthOrder,
  String address,
) async {
  await FirebaseFirestore.instance.collection('Creators').doc(id).update({
    'memberDetails': {
      'fullName': name,
      'phoneNum': phoneNum,
      'birthOrder': birthOrder,
      'birthDate': birthDate,
      'address': address,
    },
  }).then((_) {
    print('Creator details updated successfully!');
  }).catchError((error) {
    print('Failed to update creator details: $error');
  });
}

Future<CreatorDB?> getCreatorData(String id) async {
  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Creators').doc(id).get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String email = snapshot['email'];
      String famLegacyID = snapshot['famLegacyID'];
      Map<String, dynamic> memberDetails = snapshot['memberDetails'];

      return CreatorDB(
        id: id,
        email: email,
        famLegacyID: famLegacyID,
        memberDetails: memberDetails,
      );
    }
  } catch (error) {
    print('Failed to retrieve Creator data: $error');
  }

  return null;
}

Future registerCreatorDB(
  String id,
  String email,
  String famLegacyID,
  Map<String, dynamic> memberDetails,
) async {
  await FirebaseFirestore.instance.collection('Creators').doc(id).set({
    'id': id,
    'email': email,
    'famLegacyID': famLegacyID,
    'memberDetails': memberDetails,
  }).then((_) {
    print('Successfully store Creator details into database !');
  }).catchError((error) {
    print('Failed to store Creator details into database: $error');
  });
}

Future registerCreator(
  String email,
  String password,
  String name,
  String phoneNum,
  int birthOrder,
  Timestamp birthDate,
  String address,
) async {
  try {
    Timestamp dateCreate = Timestamp.now();
    String famLegacyID = _generateLegacyID(name);

    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {
      CreatorDB c = CreatorDB(
        id: user.uid,
        email: email,
        famLegacyID: famLegacyID,
        memberDetails: {
          'fullName': name,
          'phoneNum': phoneNum,
          'birthDate': birthDate,
          'birthOrder': birthOrder,
          'address': address,
        },
      );

      await registerCreatorDB(
        c.id,
        email,
        famLegacyID,
        c.memberDetails,
      );

      await createFamLegacyCreatorDetails(
        c.id,
        name,
        email,
        famLegacyID,
        dateCreate,
      );

      await createListOfMember(
        famLegacyID,
        c.id,
        name,
        birthOrder,
        birthDate,
        'Creator',
        false,
      );

      await createUserRoleDB(
        c.email,
        c.id,
        'Creators',
      );

      createListOfAllMember(
        famLegacyID,
        c.id,
        name,
        birthOrder,
        birthDate,
        Timestamp.fromDate(DateTime(1900, 1, 1)),
        'Living Creator',
      );

      print('Successfully register Creator !');
    }
  } catch (e) {
    print('Failed to register Creator: $e');
  }
}

String _generateLegacyID(String name) {
  String nameWithRandom = name + Random().nextInt(999999).toString();
  List<String> nameCharacters = nameWithRandom.split('');
  nameCharacters.shuffle();

  nameCharacters.removeWhere((character) => character == ' ');

  if (nameCharacters.length > 15) {
    nameCharacters = nameCharacters.sublist(0, 15);
  }

  return nameCharacters.join('');
}
