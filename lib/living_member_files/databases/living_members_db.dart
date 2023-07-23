// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class LivingMemberDB {
  final String id;
  final String name;
  final int birthOrder;
  final Timestamp birthDate;
  final String memberRole;
  final bool requestStatus;

  LivingMemberDB({
    required this.id,
    required this.name,
    required this.birthOrder,
    required this.birthDate,
    required this.memberRole,
    required this.requestStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthOrder': birthOrder,
      'birthDate': birthDate,
      'memberRole': memberRole,
      'requestStatus': requestStatus,
    };
  }

  factory LivingMemberDB.fromJson(Map<String, dynamic> json) {
    return LivingMemberDB(
      id: json['id'] as String,
      name: json['name'] as String,
      birthOrder: json['birthOrder'] as int,
      birthDate: json['birthDate'] as Timestamp,
      memberRole: json['memberRole'] as String,
      requestStatus: json['requestStatus'] as bool,
    );
  }
}

Future deleteLivingMembers(String famLegacyID, String memberID) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfDeceasedMember')
        .doc(memberID)
        .delete();

    print('Success Delete Living Member');
  } catch (error) {
    print('Error delete living member: $error');
  }
}

Future updateMemberRoleRequestStatus(
  String famLegacyID,
  String id,
  bool requestStatus,
) async {
  final requestStatusRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfLivingMembers')
      .doc(id);

  try {
    await requestStatusRef.update({'requestStatus': requestStatus});

    print('Updated request status role successfully!');
  } catch (error) {
    print('Failed to update request status role role: $error');
  }
}

Future<LivingMemberDB?> getMemberRoleRequestData(
    String famLegacyID, String id) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfLivingMembers')
        .doc(id)
        .get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String name = snapshot['name'];
      String memberRole = snapshot['memberRole'];
      Timestamp birthDate = snapshot['birthDate'];
      int birthOrder = snapshot['birthOrder'];
      bool requestStatus = snapshot['requestStatus'];

      return LivingMemberDB(
        id: id,
        name: name,
        memberRole: memberRole,
        birthDate: birthDate,
        birthOrder: birthOrder,
        requestStatus: requestStatus,
      );
    }
  } catch (e) {
    print('Failed to retrieve Member Role Request data: $e');
  }

  return null;
}

Stream<List<LivingMemberDB>> readListOfFamLegacyMembers(String famLegacyID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfLivingMembers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LivingMemberDB.fromJson(doc.data()))
            .toList());

Future deleteRequest(String famLegacyID, String id) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfMemberRequest')
        .doc(id)
        .delete();
  } catch (error) {
    print('Error rejecting request: $error');
  }
}

Future updateFamLegacyMemberRole(
  String famLegacyID,
  String id,
  String memberRole,
  bool requestStatus,
) async {
  final legacyMemberRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfLivingMembers')
      .doc(id);

  final memberRef = FirebaseFirestore.instance.collection('Members').doc(id);

  try {
    await legacyMemberRef.update({
      'memberRole': memberRole,
      'requestStatus': requestStatus,
    });
    await memberRef.update({
      'memberRole': memberRole,
    });
    print('Updated member role successfully!');
  } catch (error) {
    print('Failed to update member role: $error');
  }
}

Future createListOfMember(
  String famLegacyID,
  String id,
  String name,
  int birthOrder,
  Timestamp birthDate,
  String memberRole,
  bool requestStatus,
) async {
  final famLegacyMemberRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfLivingMembers')
      .doc(id);

  final famLegacyMemberData = {
    'id': id,
    'name': name,
    'birthOrder': birthOrder,
    'birthDate': birthDate,
    'memberRole': memberRole,
    'requestStatus': requestStatus,
  };

  try {
    await famLegacyMemberRef.set(famLegacyMemberData);
    print('Successfully create Legacy Member !');
  } catch (e) {
    print('Failed to create Legacy Member: $e');
  }
}
