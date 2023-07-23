// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class ChildDB {
  final String childID,
      childid,
      childName,
      childStatus,
      childSpouseid,
      childSpouseName,
      childSpouseStatus;
  final int childBirthOrder;
  final bool marriage;

  ChildDB({
    required this.childID,
    required this.childid,
    required this.childName,
    required this.childStatus,
    required this.childBirthOrder,
    required this.childSpouseid,
    required this.childSpouseName,
    required this.childSpouseStatus,
    required this.marriage,
  });

  Map<String, dynamic> toJson() {
    return {
      'childID': childID,
      'childid': childid,
      'childName': childName,
      'childStatus': childStatus,
      'childBirthOrder': childBirthOrder,
      'spouseid': childSpouseid,
      'spouseName': childSpouseName,
      'spouseStatus': childSpouseStatus,
      'marriage': marriage,
    };
  }

  factory ChildDB.fromJson(Map<String, dynamic> json) {
    return ChildDB(
      childID: json['childID'] as String,
      childid: json['childid'] as String,
      childName: json['childName'] as String,
      childStatus: json['childStatus'] as String,
      childBirthOrder: json['childBirthOrder'] as int,
      childSpouseid: json['childSpouseid'] as String,
      childSpouseName: json['childSpouseName'] as String,
      childSpouseStatus: json['childSpouseStatus'] as String,
      marriage: json['marriage'] as bool,
    );
  }
}

Stream<List<ChildDB>> readChildFromParent(
  String famLegacyID,
  String grandparentID,
  String parentID,
) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .doc(grandparentID)
        .collection('Parents')
        .doc(parentID)
        .collection('Children')
        .orderBy('childBirthOrder')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChildDB.fromJson(doc.data())).toList());

Future deleteChildFromParent(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String childID,
) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .doc(grandparentID)
        .collection('Parents')
        .doc(parentID)
        .collection('Children')
        .doc(childID)
        .delete();
  } catch (error) {
    print('Error delete child: $error');
  }
}

Future updateChildFromParent(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String childID,
  String childid,
  String childName,
  String childStatus,
  int childBirthOrder,
  String childSpouseid,
  String childSpouseName,
  String childSpouseStatus,
  bool marriage,
) async {
  final childRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID)
      .collection('Parents')
      .doc(parentID)
      .collection('Children')
      .doc(childID);

  final childData = {
    'childID': childID,
    'childid': childid,
    'childName': childName,
    'childStatus': childStatus,
    'childBirthOrder': childBirthOrder,
    'childSpouseid': childSpouseid,
    'childSpouseName': childSpouseName,
    'childSpouseStatus': childSpouseStatus,
    'marriage': marriage,
  };

  try {
    await childRef.update(childData);

    print('Successfully update child !');
  } catch (e) {
    print('Failed to update child: $e');
  }
}

Future createChildFromParent(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String childid,
  String childName,
  String childStatus,
  int childBirthOrder,
  String childSpouseid,
  String childSpouseName,
  String childSpouseStatus,
  bool marriage,
) async {
  final childRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID)
      .collection('Parents')
      .doc(parentID)
      .collection('Children')
      .doc();

  final childData = {
    'childID': childRef.id,
    'childid': childid,
    'childName': childName,
    'childStatus': childStatus,
    'childBirthOrder': childBirthOrder,
    'childSpouseid': childSpouseid,
    'childSpouseName': childSpouseName,
    'childSpouseStatus': childSpouseStatus,
    'marriage': marriage,
  };

  try {
    await childRef.set(childData);

    print('Successfully create child !');
  } catch (e) {
    print('Failed to create child: $e');
  }
}
