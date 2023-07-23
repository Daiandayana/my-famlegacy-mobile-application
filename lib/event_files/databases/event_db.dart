// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class EventNotificationDB {
  final String eventID,
      eventName,
      eventLocation,
      eventTime,
      createBy,
      permissionID;
  final Timestamp eventDate;

  EventNotificationDB({
    required this.eventID,
    required this.eventName,
    required this.eventTime,
    required this.eventDate,
    required this.eventLocation,
    required this.createBy,
    required this.permissionID,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventID': eventID,
      'eventName': eventName,
      'eventTime': eventTime,
      'eventDate': eventDate,
      'eventLocation': eventLocation,
      'createBy': createBy,
      'permissionID': permissionID,
    };
  }

  factory EventNotificationDB.fromJson(Map<String, dynamic> json) {
    return EventNotificationDB(
      eventID: json['eventID'] as String,
      eventName: json['eventName'] as String,
      eventTime: json['eventTime'] as String,
      eventDate: json['eventDate'] as Timestamp,
      eventLocation: json['eventLocation'] as String,
      createBy: json['createBy'] as String,
      permissionID: json['permissionID'] as String,
    );
  }
}

Stream<List<EventNotificationDB>> readEventNotifications(String famLegacyID) =>
    FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('EventNotifications')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventNotificationDB.fromJson(doc.data()))
            .toList());

Future deleteEventNotifications(String famLegacyID, String eventID) async {
  try {
    await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('EventNotifications')
        .doc(eventID)
        .delete();
  } catch (error) {
    print('Error delete Event Notifications: $error');
  }
}

Future<EventNotificationDB?> getEventNotification(
    String famLegacyID, String eventID) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Legacies')
        .doc(famLegacyID)
        .collection('EventNotifications')
        .doc(eventID)
        .get();

    if (snapshot.exists) {
      String eventID = snapshot['eventID'];
      String eventName = snapshot['eventName'];
      String eventLocation = snapshot['eventLocation'];
      String eventTime = snapshot['eventTime'];
      String createBy = snapshot['createBy'];
      String permissionID = snapshot['permissionID'];
      Timestamp eventDate = snapshot['eventDate'];

      return EventNotificationDB(
        eventID: eventID,
        eventName: eventName,
        eventLocation: eventLocation,
        eventTime: eventTime,
        createBy: createBy,
        permissionID: permissionID,
        eventDate: eventDate,
      );
    }
  } catch (e) {
    print('Failed to retrieve All Member data: $e');
  }

  return null;
}

Future updateEventNotification(
  String famLegacyID,
  String eventID,
  String eventName,
  String eventTime,
  Timestamp eventDate,
  String eventLocation,
  String createBy,
  String permissionID,
) async {
  final eventRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('EventNotifications')
      .doc(eventID);

  final eventData = {
    'eventID': eventID,
    'eventName': eventName,
    'eventTime': eventTime,
    'eventDate': eventDate,
    'eventLocation': eventLocation,
    'createBy': createBy,
    'permissionID': permissionID,
  };

  try {
    await eventRef.update(eventData);

    print('Successfully update Event Notification !');
  } catch (e) {
    print('Failed to update Event Notification: $e');
  }
}

Future createEventNotification(
  String famLegacyID,
  String eventName,
  String eventTime,
  Timestamp eventDate,
  String eventLocation,
  String createBy,
  String permissionID,
) async {
  final eventRef = FirebaseFirestore.instance
      .collection('Legacies')
      .doc(famLegacyID)
      .collection('EventNotifications')
      .doc();

  final eventData = {
    'eventID': eventRef.id,
    'eventName': eventName,
    'eventTime': eventTime,
    'eventDate': eventDate,
    'eventLocation': eventLocation,
    'createBy': createBy,
    'permissionID': permissionID,
  };

  try {
    await eventRef.set(eventData);

    print('Successfully create Event Notification !');
  } catch (e) {
    print('Failed to create Event Notification: $e');
  }
}
