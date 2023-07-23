// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class ParentDB {
  final String parentID,
      parentid,
      parentName,
      parentStatus,
      parentSpouseid,
      parentSpouseName,
      parentSpouseStatus;
  final int parentBirthOrder;
  final bool marriage;

  ParentDB({
    required this.parentID,
    required this.parentid,
    required this.parentName,
    required this.parentStatus,
    required this.parentBirthOrder,
    required this.parentSpouseid,
    required this.parentSpouseName,
    required this.parentSpouseStatus,
    required this.marriage,
  });

  Map<String, dynamic> toJson() {
    return {
      'parentID': parentID,
      'parentid': parentid,
      'parentName': parentName,
      'parentStatus': parentStatus,
      'parentBirthOrder': parentBirthOrder,
      'parentSpouseid': parentSpouseid,
      'parentSpouseName': parentSpouseName,
      'parentSpouseStatus': parentSpouseStatus,
      'marriage': marriage,
    };
  }

  factory ParentDB.fromJson(Map<String, dynamic> json) {
    return ParentDB(
      parentID: json['parentID'] as String,
      parentid: json['parentid'] as String,
      parentName: json['parentName'] as String,
      parentStatus: json['parentStatus'] as String,
      parentBirthOrder: json['parentBirthOrder'] as int,
      parentSpouseid: json['parentSpouseid'] as String,
      parentSpouseName: json['parentSpouseName'] as String,
      parentSpouseStatus: json['parentSpouseStatus'] as String,
      marriage: json['marriage'] as bool,
    );
  }
}

Stream<List<ParentDB>> readParentFromGrandparent(
        String famLegacyID, String grandparentID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .doc(grandparentID)
        .collection('Parents')
        .orderBy('parentBirthOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ParentDB.fromJson(doc.data())).toList());

Future deleteParentFromGrandparent(
    String famLegacyID, String grandparentID, String parentID) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .doc(grandparentID)
        .collection('Parents')
        .doc(parentID)
        .delete();
  } catch (error) {
    print('Error delete Parent Family Legacies: $error');
  }
}

Future updateParentFromGrandparent(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String parentid,
  String parentName,
  String parentStatus,
  int parentBirthOrder,
  String parentSpouseid,
  String parentSpouseName,
  String parentSpouseStatus,
  bool marriage,
) async {
  final parentRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID)
      .collection('Parents')
      .doc(parentID);

  try {
    await parentRef.update({
      'parentID': parentID,
      'parentid': parentid,
      'parentName': parentName,
      'parentStatus': parentStatus,
      'parentBirthOrder': parentBirthOrder,
      'parentSpouseid': parentSpouseid,
      'parentSpouseName': parentSpouseName,
      'parentSpouseStatus': parentSpouseStatus,
      'marriage': marriage,
    });

    print('Successfully update parent !');
  } catch (error) {
    print('Failed to update parent: $error');
  }
}

Future createParentFromGrandparent(
  String famLegacyID,
  String grandparentID,
  String parentid,
  String parentName,
  String parentStatus,
  int parentBirthOrder,
  String parentSpouseid,
  String parentSpouseName,
  String parentSpouseStatus,
  bool marriage,
) async {
  final parentRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID)
      .collection('Parents')
      .doc();

  final parentData = {
    'parentID': parentRef.id,
    'parentid': parentid,
    'parentName': parentName,
    'parentStatus': parentStatus,
    'parentBirthOrder': parentBirthOrder,
    'parentSpouseid': parentSpouseid,
    'parentSpouseName': parentSpouseName,
    'parentSpouseStatus': parentSpouseStatus,
    'marriage': marriage,
  };

  try {
    await parentRef.set(parentData);

    print('Successfully create parent !');
  } catch (e) {
    print('Failed to create parent: $e');
  }
}
