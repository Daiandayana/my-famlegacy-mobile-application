// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class GrandchildDB {
  final String grandchildID, id, name, status;
  final int birthOrder;

  GrandchildDB({
    required this.grandchildID,
    required this.id,
    required this.name,
    required this.status,
    required this.birthOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'grandchildID': grandchildID,
      'id': id,
      'name': name,
      'status': status,
      'birthOrder': birthOrder,
    };
  }

  factory GrandchildDB.fromJson(Map<String, dynamic> json) {
    return GrandchildDB(
      grandchildID: json['grandchildID'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      birthOrder: json['birthOrder'] as int,
    );
  }
}

Stream<List<GrandchildDB>> readGrandchildFromChild(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String childID,
) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('Grandparents')
        .doc(grandparentID)
        .collection('Parents')
        .doc(parentID)
        .collection('Children')
        .doc(childID)
        .collection('Grandchildren')
        .orderBy('birthOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrandchildDB.fromJson(doc.data()))
            .toList());

Future deleteGrandchildFromChild(String famLegacyID, String grandparentID,
    String parentID, String childID, String grandchildID) async {
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
        .collection('Grandchildren')
        .doc(grandchildID)
        .delete();
  } catch (error) {
    print('Error delete grandchild: $error');
  }
}

Future updateGrandchildFromChild(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String childID,
  String grandchildID,
  String id,
  String name,
  int birthOrder,
  String status,
) async {
  final grandchildRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID)
      .collection('Parents')
      .doc(parentID)
      .collection('Children')
      .doc(childID)
      .collection('Grandchildren')
      .doc(grandchildID);

  final grandchildData = {
    'grandchildID': grandchildID,
    'id': id,
    'name': name,
    'birthOrder': birthOrder,
    'status': status,
  };

  try {
    await grandchildRef.update(grandchildData);

    print('Successfully update grandchild !');
  } catch (e) {
    print('Failed to update grandchild: $e');
  }
}

Future createGrandchildFromChild(
  String famLegacyID,
  String grandparentID,
  String parentID,
  String childID,
  String id,
  String name,
  int birthOrder,
  String status,
) async {
  final grandchildRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('Grandparents')
      .doc(grandparentID)
      .collection('Parents')
      .doc(parentID)
      .collection('Children')
      .doc(childID)
      .collection('Grandchildren')
      .doc();

  final grandchildData = {
    'grandchildID': grandchildRef.id,
    'id': id,
    'name': name,
    'birthOrder': birthOrder,
    'status': status,
  };

  try {
    await grandchildRef.set(grandchildData);

    print('Successfully create grandchild !');
  } catch (e) {
    print('Failed to create grandchild: $e');
  }
}
