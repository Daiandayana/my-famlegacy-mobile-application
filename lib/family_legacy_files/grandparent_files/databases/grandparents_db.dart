// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class GrandparentDB {
  final String grandparentID,
      grandparentid,
      grandparentName,
      grandparentStatus,
      grandparentSpouseid,
      grandparentSpouseName,
      grandparentSpouseStatus;
  final int grandparentBirthOrder, grandparentSpouseBirthOrder;
  final bool marriage;

  GrandparentDB({
    required this.grandparentID,
    required this.grandparentid,
    required this.grandparentName,
    required this.grandparentStatus,
    required this.grandparentSpouseid,
    required this.grandparentSpouseName,
    required this.grandparentSpouseStatus,
    required this.grandparentBirthOrder,
    required this.grandparentSpouseBirthOrder,
    required this.marriage,
  });

  Map<String, dynamic> toJson() {
    return {
      'grandparentID': grandparentID,
      'grandparentid': grandparentid,
      'grandparentName': grandparentName,
      'grandparentStatus': grandparentStatus,
      'grandparentSpouseid': grandparentSpouseid,
      'grandparentSpouseName': grandparentSpouseName,
      'grandparentSpouseStatus': grandparentSpouseStatus,
      'grandparentBirthOrder': grandparentBirthOrder,
      'grandparentSpouseBirthOrder': grandparentSpouseBirthOrder,
      'marriage': marriage,
    };
  }

  factory GrandparentDB.fromJson(Map<String, dynamic> json) {
    return GrandparentDB(
      grandparentID: json['grandparentID'] as String,
      grandparentid: json['grandparentid'] as String,
      grandparentName: json['grandparentName'] as String,
      grandparentStatus: json['grandparentStatus'] as String,
      grandparentSpouseid: json['grandparentSpouseid'] as String,
      grandparentSpouseName: json['grandparentSpouseName'] as String,
      grandparentSpouseStatus: json['grandparentSpouseStatus'] as String,
      grandparentBirthOrder: json['grandparentBirthOrder'] as int,
      grandparentSpouseBirthOrder: json['grandparentSpouseBirthOrder'] as int,
      marriage: json['marriage'] as bool,
    );
  }
}

Stream<List<GrandparentDB>> readGrandparent(String famLegacyID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .orderBy('grandparentBirthOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrandparentDB.fromJson(doc.data()))
            .toList());

Future deleteGrandParent(String famLegacyID, String grandparentID) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .doc(grandparentID)
        .delete();
  } catch (error) {
    print('Error delete Grandparent Legacies: $error');
  }
}

Future updateGrandparent(
  String famLegacyID,
  String grandparentID,
  String grandparentid,
  String grandparentName,
  String grandparentStatus,
  int grandparentBirthOrder,
  String grandparentSpouseid,
  String grandparentSpouseName,
  String grandparentSpouseStatus,
  int grandparentSpouseBirthOrder,
  bool marriage,
) async {
  final legacyMemberRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID);

  try {
    await legacyMemberRef.update({
      'grandparentID': grandparentID,
      'grandparentid': grandparentid,
      'grandparentName': grandparentName,
      'grandparentStatus': grandparentStatus,
      'grandparentSpouseid': grandparentSpouseid,
      'grandparentSpouseName': grandparentSpouseName,
      'grandparentSpouseStatus': grandparentSpouseStatus,
      'grandparentBirthOrder': grandparentBirthOrder,
      'grandparentSpouseBirthOrder': grandparentSpouseBirthOrder,
      'marriage': marriage,
    });

    print('Updated Grandparent successfully!');
  } catch (error) {
    print('Failed to update Grandparent: $error');
  }
}

Future createGrandparent(
  String famLegacyID,
  String grandparentid,
  String grandparentName,
  String grandparentStatus,
  int grandparentBirthOrder,
  String grandparentSpouseid,
  String grandparentSpouseName,
  String grandparentSpouseStatus,
  int grandparentSpouseBirthOrder,
  bool marriage,
) async {
  final grandparentRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc();

  final grandparentData = {
    'grandparentID': grandparentRef.id,
    'grandparentid': grandparentid,
    'grandparentName': grandparentName,
    'grandparentStatus': grandparentStatus,
    'grandparentSpouseid': grandparentSpouseid,
    'grandparentSpouseName': grandparentSpouseName,
    'grandparentSpouseStatus': grandparentSpouseStatus,
    'grandparentBirthOrder': grandparentBirthOrder,
    'grandparentSpouseBirthOrder': grandparentSpouseBirthOrder,
    'marriage': marriage,
  };

  try {
    await grandparentRef.set(grandparentData);

    print('Successfully create Grandparent !');
  } catch (e) {
    print('Failed to create Grandparent: $e');
  }
}
