import 'package:flutter/material.dart';
import 'package:my_famlegacy/event_files/databases/presence_db.dart';

class EventPresence extends StatefulWidget {
  final String famLegacyID, eventID, eventName;

  const EventPresence({
    super.key,
    required this.famLegacyID,
    required this.eventID,
    required this.eventName,
  });

  @override
  State<EventPresence> createState() => _EventPresenceState();
}

class _EventPresenceState extends State<EventPresence> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.eventName),
        ),
        body: StreamBuilder<List<PresenceDB>>(
            stream: readPresenceStatus(widget.famLegacyID, widget.eventID),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final presenceDB = snapshot.data!;

                return ListView.builder(
                    itemCount: presenceDB.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text('Name : ${presenceDB[index].famName}'),
                          subtitle: Text(
                              'Status : ${presenceDB[index].presenceStatus}'),
                        ),
                      );
                    });
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return const Center(
                  child: Text('No member found.'),
                );
              }
            }));
  }
}
