// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceDB {
  final String famName, famID, presenceStatus;

  PresenceDB({
    required this.famID,
    required this.famName,
    required this.presenceStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'famID': famID,
      'famName': famName,
      'presenceStatus': presenceStatus,
    };
  }

  factory PresenceDB.fromJson(Map<String, dynamic> json) {
    return PresenceDB(
      famID: json['famID'] as String,
      famName: json['famName'] as String,
      presenceStatus: json['presenceStatus'] as String,
    );
  }
}

Stream<List<PresenceDB>> readPresenceStatus(
        String famLegacyID, String eventID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('EventNotifications')
        .doc(eventID)
        .collection('MembersPresence')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PresenceDB.fromJson(doc.data()))
            .toList());

Future<PresenceDB?> getPresenceDB(
    String famLegacyID, String eventID, String memberID) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('EventNotifications')
        .doc(eventID)
        .collection('MembersPresence')
        .doc(memberID)
        .get();

    if (snapshot.exists) {
      String famID = snapshot['famID'];
      String famName = snapshot['famName'];
      String presenceStatus = snapshot['presenceStatus'];

      return PresenceDB(
        famID: famID,
        famName: famName,
        presenceStatus: presenceStatus,
      );
    }
  } catch (e) {
    print('Failed to retrieve All Member data: $e');
  }

  return null;
}

Future deletePresenceStatus(
    String famLegacyID, String eventID, String famID) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('EventNotifications')
        .doc(eventID)
        .collection('MembersPresence')
        .doc(famID)
        .delete();
  } catch (error) {
    print('Error delete Event Notifications: $error');
  }
}

Future updatePresenceStatus(
  String famLegacyID,
  String eventID,
  String famID,
  String famName,
  String presenceStatus,
) async {
  final presenceRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('EventNotifications')
      .doc(eventID)
      .collection('MembersPresence')
      .doc(famID);

  final presenceData = {
    'famID': famID,
    'famName': famName,
    'presenceStatus': presenceStatus,
  };

  try {
    await presenceRef.update(presenceData);

    print('Successfully update Event Notification !');
  } catch (e) {
    print('Failed to create Event Notification: $e');
  }
}

Future createPresenceStatus(
  String famLegacyID,
  String eventID,
  String famID,
  String famName,
  String presenceStatus,
) async {
  final presenceRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('EventNotifications')
      .doc(eventID)
      .collection('MembersPresence')
      .doc(famID);

  final presenceData = {
    'famID': famID,
    'famName': famName,
    'presenceStatus': presenceStatus,
  };

  try {
    await presenceRef.set(presenceData);

    print('Successfully create Event Notification !');
  } catch (e) {
    print('Failed to create Event Notification: $e');
  }
}
