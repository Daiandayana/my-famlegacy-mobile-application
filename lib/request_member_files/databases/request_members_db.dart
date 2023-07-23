// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class RequestFamLegacyMembers {
  final String id;
  final String name;
  final String email;
  final Timestamp dateRequested;

  RequestFamLegacyMembers({
    required this.id,
    required this.name,
    required this.email,
    required this.dateRequested,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dateRequested': dateRequested,
    };
  }

  factory RequestFamLegacyMembers.fromJson(Map<String, dynamic> json) {
    return RequestFamLegacyMembers(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      dateRequested: json['dateRequested'] as Timestamp,
    );
  }
}

Stream<List<RequestFamLegacyMembers>> readRequestOfFamLegacyMembers(
        String famLegacyID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfMemberRequest')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestFamLegacyMembers.fromJson(doc.data()))
            .toList());

Future<RequestFamLegacyMembers?> getNewMemberRequestData(
    String famLegacyID, String id) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('ListOfMemberRequest')
        .doc(id)
        .get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String name = snapshot['name'];
      String email = snapshot['email'];
      Timestamp dateRequested = snapshot['dateRequested'];

      return RequestFamLegacyMembers(
        id: id,
        name: name,
        email: email,
        dateRequested: dateRequested,
      );
    }
  } catch (e) {
    print('Failed to retrieve Member Role Request data: $e');
  }

  return null;
}

Future createRequestFamLegacyMember(
  String famLegacyID,
  String id,
  String name,
  String email,
) async {
  final joinLegacyDocRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('ListOfMemberRequest')
      .doc(id);

  final newMemberData = {
    'id': id,
    'name': name,
    'email': email,
    'dateRequested': Timestamp.now(),
  };

  try {
    await joinLegacyDocRef.set(newMemberData);
    print('New member details create successfully!');
  } catch (error) {
    print('Failed to create Legacy details: $error');
  }
}

Future updateRequestMember(
  String famLegacyID,
  String id,
  String name,
  bool requestLegacy,
  bool joinedLegacy,
) async {
  final updateRequest =
      FirebaseFirestore.instance.collection('Members').doc(id);

  final updateRequestData = {
    'legacyDetails': {
      'famLegacyID': famLegacyID,
      'creatorName': name,
      'requestLegacy': requestLegacy,
      'joinedLegacy': joinedLegacy,
    }
  };

  try {
    await updateRequest.update(updateRequestData);
    print('Update member request successfully!');
  } catch (error) {
    print('Failed to update member request: $error');
  }
}
