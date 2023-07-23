// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_famlegacy/all_member_files/databases/all_member_db.dart';

class DeceasedMemberDB {
  final String id;
  final String name;
  final int birthOrder;
  final Timestamp birthDate;
  final Timestamp deathDate;
  final String createBy;

  DeceasedMemberDB({
    required this.id,
    required this.name,
    required this.birthOrder,
    required this.birthDate,
    required this.deathDate,
    required this.createBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthOrder': birthOrder,
      'birthDate': birthDate,
      'deathDate': deathDate,
      'createBy': createBy,
    };
  }

  factory DeceasedMemberDB.fromJson(Map<String, dynamic> json) {
    return DeceasedMemberDB(
      id: json['id'] as String,
      name: json['name'] as String,
      birthOrder: json['birthOrder'] as int,
      birthDate: json['birthDate'] as Timestamp,
      deathDate: json['deathDate'] as Timestamp,
      createBy: json['createBy'] as String,
    );
  }
}

Stream<List<DeceasedMemberDB>> readListOfDeceasedMembers(String famLegacyID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfDeceasedMembers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DeceasedMemberDB.fromJson(doc.data()))
            .toList());

Future deleteDeceasedMember(String famLegacyID, String id) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfDeceasedMembers')
        .doc(id)
        .delete();
  } catch (error) {
    print('Error delete Deceased Member: $error');
  }
}

Future<DeceasedMemberDB?> getDeceasedMemberData(
    String famLegacyID, String id) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfDeceasedMembers')
        .doc(id)
        .get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String name = snapshot['name'];
      int birthOrder = snapshot['birthOrder'];
      Timestamp birthDate = snapshot['birthDate'];
      Timestamp deathDate = snapshot['deathDate'];
      String createBy = snapshot['createBy'];

      return DeceasedMemberDB(
        id: id,
        name: name,
        birthOrder: birthOrder,
        birthDate: birthDate,
        deathDate: deathDate,
        createBy: createBy,
      );
    }
  } catch (error) {
    print('Failed to retrieve Creator data: $error');
  }

  return null;
}

Future updateDeceasedMember(
  String famLegacyID,
  String memberID,
  String name,
  int birthOrder,
  Timestamp birthDate,
  Timestamp deathDate,
) async {
  final legacyMemberRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfDeceasedMembers')
      .doc(memberID);

  try {
    await legacyMemberRef.update({
      'id': memberID,
      'name': name,
      'birthOrder': birthOrder,
      'birthDate': birthDate,
      'deathDate': deathDate,
    });

    print('Updated Deceased Member successfully!');
  } catch (error) {
    print('Failed to update Deceased Member role: $error');
  }
}

Future createNaturalDeceasedMember(
  String famLegacyID,
  String name,
  int birthOrder,
  Timestamp birthDate,
  Timestamp deathDate,
  String createBy,
) async {
  final famLegacyMemberRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfDeceasedMembers')
      .doc();

  final famLegacyMemberData = {
    'id': famLegacyMemberRef.id,
    'name': name,
    'birthOrder': birthOrder,
    'birthDate': birthDate,
    'deathDate': deathDate,
    'createBy': createBy,
  };

  try {
    await famLegacyMemberRef.set(famLegacyMemberData);

    await createListOfAllMember(
      famLegacyID,
      famLegacyMemberRef.id,
      name,
      birthOrder,
      birthDate,
      deathDate,
      'Deceased',
    );

    print('Successfully create Deceased Member !');
  } catch (e) {
    print('Failed to create Deceased Member: $e');
  }
}

Future createChangeDeceasedMember(
  String famLegacyID,
  String id,
  String name,
  int birthOrder,
  Timestamp birthDate,
  Timestamp deathDate,
  String createBy,
) async {
  final famLegacyMemberRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfDeceasedMembers')
      .doc(id);

  final famLegacyMemberData = {
    'id': id,
    'name': name,
    'birthOrder': birthOrder,
    'birthDate': birthDate,
    'deathDate': deathDate,
    'createBy': createBy,
  };

  try {
    await famLegacyMemberRef.set(famLegacyMemberData);

    await createListOfAllMember(
      famLegacyID,
      id,
      name,
      birthOrder,
      birthDate,
      deathDate,
      'Deceased',
    );

    print('Successfully create Deceased Member !');
  } catch (e) {
    print('Failed to create Deceased Member: $e');
  }
}
