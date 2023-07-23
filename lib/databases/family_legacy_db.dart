// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FamLegacyDB {
  final String creatorID;
  final String creatorName;
  final String creatorEmail;
  final String famLegacyID;
  final Timestamp dateCreate;

  FamLegacyDB({
    required this.creatorID,
    required this.creatorName,
    required this.creatorEmail,
    required this.dateCreate,
    required this.famLegacyID,
  });

  Map<String, dynamic> toJson() {
    return {
      'creatorID': creatorID,
      'creatorName': creatorName,
      'creatorEmail': creatorEmail,
      'famLegacyID': famLegacyID,
      'dateCreate': dateCreate,
    };
  }

  factory FamLegacyDB.fromJson(Map<String, dynamic> json) {
    return FamLegacyDB(
      creatorID: json['creatorID'] as String,
      creatorName: json['creatorName'] as String,
      creatorEmail: json['creatorEmail'] as String,
      dateCreate: json['dateCreate'] as Timestamp,
      famLegacyID: json['famLegacyID'] as String,
    );
  }
}

Stream<List<FamLegacyDB>> readListOfFamLegacy() => FirebaseFirestore.instance
    .collection('Legacies')
    .snapshots()
    .map((snapshot) =>
        snapshot.docs.map((doc) => FamLegacyDB.fromJson(doc.data())).toList());

Future createFamLegacyCreatorDetails(
  String creatorID,
  String creatorName,
  String creatorEmail,
  String famLegacyID,
  Timestamp dateCreate,
) async {
  final famLegacyCreatorRef =
      FirebaseFirestore.instance.collection('Legacies').doc(famLegacyID);

  final famLegacyCreatorData = {
    'creatorID': creatorID,
    'creatorName': creatorName,
    'creatorEmail': creatorEmail,
    'famLegacyID': famLegacyID,
    'dateCreate': dateCreate,
  };

  try {
    await famLegacyCreatorRef.set(famLegacyCreatorData);
    print('Successfully create Legacy !');
  } catch (e) {
    print('Failed to create Legacy: $e');
  }
}
