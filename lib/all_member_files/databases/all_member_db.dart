// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class AllMemberDB {
  final String id;
  final String name;
  final int birthOrder;
  final Timestamp birthDate;
  final Timestamp deathDate;
  final String status;

  AllMemberDB({
    required this.id,
    required this.name,
    required this.birthOrder,
    required this.birthDate,
    required this.deathDate,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthOrder': birthOrder,
      'birthDate': birthDate,
      'deathDate': deathDate,
      'status': status,
    };
  }

  factory AllMemberDB.fromJson(Map<String, dynamic> json) {
    return AllMemberDB(
      id: json['id'] as String,
      name: json['name'] as String,
      birthOrder: json['birthOrder'] as int,
      birthDate: json['birthDate'] as Timestamp,
      status: json['status'] as String,
      deathDate: json['deathDate'] as Timestamp,
    );
  }
}

Stream<List<AllMemberDB>> readListOfAllMembers(String famLegacyID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfAllMembers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AllMemberDB.fromJson(doc.data()))
            .toList());

Future<AllMemberDB?> getAllMemberData(
  String famLegacyID,
  String memberID,
) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfAllMembers')
        .doc(memberID)
        .get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String name = snapshot['name'];
      int birthOrder = snapshot['birthOrder'];
      Timestamp birthDate = snapshot['birthDate'];
      Timestamp deathDate = snapshot['deathDate'];
      String status = snapshot['status'];

      return AllMemberDB(
          id: id,
          name: name,
          birthOrder: birthOrder,
          birthDate: birthDate,
          deathDate: deathDate,
          status: status);
    }
  } catch (e) {
    print('Failed to retrieve All Member data: $e');
  }

  return null;
}

Future deleteListOfAllMember(String famLegacyID, String id) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfAllMembers')
        .doc(id)
        .delete();
  } catch (error) {
    print('Error delete Member: $error');
  }
}

Future updateListOfAllMember(
  String? famLegacyID,
  String id,
  String name,
  int birthOrder,
  Timestamp birthDate,
  Timestamp deathDate,
  String status,
) async {
  final listAllMembersRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfAllMembers')
      .doc(id);

  final listAllMemberData = {
    'id': id,
    'name': name,
    'birthOrder': birthOrder,
    'birthDate': birthDate,
    'deathDate': deathDate,
    'status': status,
  };

  try {
    await listAllMembersRef.update(listAllMemberData);
    print('Successfully update Status Member !');
  } catch (e) {
    print('Failed to update Status Member: $e');
  }
}

Future createListOfAllMember(
  String famLegacyID,
  String id,
  String name,
  int birthOrder,
  Timestamp birthDate,
  Timestamp deathDate,
  String status,
) async {
  final listAllMembersRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfAllMembers')
      .doc(id);

  final listAllMemberData = {
    'id': id,
    'name': name,
    'birthOrder': birthOrder,
    'birthDate': birthDate,
    'deathDate': deathDate,
    'status': status,
  };

  try {
    await listAllMembersRef.set(listAllMemberData);
    print('Successfully create Status Member !');
  } catch (e) {
    print('Failed to create Status Member: $e');
  }
}
