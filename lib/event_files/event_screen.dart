// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/event_files/databases/event_db.dart';
import 'package:my_famlegacy/event_files/event_presence.dart';
import 'package:my_famlegacy/event_files/functions/create_event.dart';
import 'package:my_famlegacy/event_files/functions/edit_event.dart';
import 'package:my_famlegacy/event_files/member_functions/choice_presence.dart';
import 'package:my_famlegacy/screens/drawers/creator_drawer.dart';
import 'package:my_famlegacy/screens/drawers/member_drawer.dart';
import 'package:my_famlegacy/screens/landing_screen.dart';
import 'package:my_famlegacy/widgets/widget_area.dart';

class EventScreen extends StatefulWidget {
  final String userID;

  const EventScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  CreatorDB? _cSnapshot;
  MemberDB? _mSnapshot;
  String _famLegacyID = '', _memberRole = '', _createName = '';
  bool isCreator = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.userID);
      MemberDB? mSnapshot = await getMemberData(widget.userID);

      if (cSnapshot != null) {
        _famLegacyID = cSnapshot.famLegacyID;
        _createName = cSnapshot.memberDetails['fullName'];
        isCreator = true;
      } else if (mSnapshot != null) {
        _famLegacyID = mSnapshot.legacyDetails['famLegacyID'];
        _createName = mSnapshot.memberDetails['fullName'];
        _memberRole = mSnapshot.memberRole;
      }

      setState(() {
        _cSnapshot = cSnapshot;
        _mSnapshot = mSnapshot;
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isCreator == false
          ? MemberDrawer(
              userID: widget.userID,
            )
          : CreatorDrawer(
              userID: widget.userID,
            ),
      appBar: AppBar(
        title: const Text('Event Notifications'),
        actions: [
          if (_memberRole == 'High Member')
            IconButton(
              icon: const Icon(Icons.create),
              tooltip: 'Create Event',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEvent(
                      userID: widget.userID,
                      famLegacyID: _famLegacyID,
                      createBy: _createName,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LandingScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _cSnapshot != null || _mSnapshot != null
          ? StreamBuilder<List<EventNotificationDB>>(
              stream: readEventNotifications(_famLegacyID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final eventNotificationDB = snapshot.data!;

                  return ListView.builder(
                    itemCount: eventNotificationDB.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        child: Align(
                          child: ListTile(
                            title: Text(
                              'Event Title : ${eventNotificationDB[index].eventName}',
                              textAlign: TextAlign.center,
                            ),
                            subtitle: Column(
                              children: [
                                const SizedBox(height: 10.0),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Event Date : ${formatTimestamp(eventNotificationDB[index].eventDate)}',
                                          ),
                                          Text(
                                              'Event Time : ${eventNotificationDB[index].eventTime}'),
                                          Text(
                                              'Organizer : ${eventNotificationDB[index].createBy}'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Event location :'),
                                          Text(eventNotificationDB[index]
                                              .eventLocation),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (eventNotificationDB[index]
                                            .permissionID ==
                                        widget.userID) ...[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => EditEvent(
                                                    userID: widget.userID,
                                                    famLegacyID: _famLegacyID,
                                                    eventID: eventNotificationDB[
                                                            index]
                                                        .eventID,
                                                    eventName:
                                                        eventNotificationDB[index]
                                                            .eventName,
                                                    eventTime:
                                                        eventNotificationDB[
                                                                index]
                                                            .eventTime,
                                                    eventDate:
                                                        eventNotificationDB[
                                                                index]
                                                            .eventDate,
                                                    eventLocation:
                                                        eventNotificationDB[
                                                                index]
                                                            .eventLocation,
                                                    createBy:
                                                        eventNotificationDB[
                                                                index]
                                                            .createBy,
                                                    permissionID:
                                                        eventNotificationDB[
                                                                index]
                                                            .permissionID)),
                                          );
                                        },
                                        child: const Text('Update Event'),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EventPresence(
                                                      famLegacyID: _famLegacyID,
                                                      eventID:
                                                          eventNotificationDB[
                                                                  index]
                                                              .eventID,
                                                      eventName:
                                                          eventNotificationDB[
                                                                  index]
                                                              .eventName),
                                            ),
                                          );
                                        },
                                        child:
                                            const Text('View Member Presence'),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          showDialog<void>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Confirmation'),
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      Text(
                                                          'Are you sure you want to delete this ${eventNotificationDB[index].eventName}?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('No'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () {
                                                      deleteEventNotifications(
                                                          _famLegacyID,
                                                          eventNotificationDB[
                                                                  index]
                                                              .eventID);

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                            content: Text(
                                                                'Event delete successfully')),
                                                      );

                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Delete Event'),
                                      ),
                                    ] else ...[
                                      ChoicePresence(
                                          userID: widget.userID,
                                          famLegacyID: _famLegacyID,
                                          eventID: eventNotificationDB[index]
                                              .eventID),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: Text('No event found.'),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
