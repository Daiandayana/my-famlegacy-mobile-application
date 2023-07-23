// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:my_famlegacy/databases/creator_db.dart';
import 'package:my_famlegacy/databases/member_db.dart';
import 'package:my_famlegacy/event_files/databases/presence_db.dart';

class ChoicePresence extends StatefulWidget {
  final String userID, famLegacyID, eventID;
  const ChoicePresence({
    super.key,
    required this.userID,
    required this.famLegacyID,
    required this.eventID,
  });

  @override
  State<ChoicePresence> createState() => _ChoicePresenceState();
}

class _ChoicePresenceState extends State<ChoicePresence> {
  String _name = '';
  String _presenceStatus = '';
  PresenceDB? _pSnapshot;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _fetchPresenceStatus();
  }

  Future<void> _fetchAllData() async {
    try {
      CreatorDB? cSnapshot = await getCreatorData(widget.userID);
      MemberDB? mSnapshot = await getMemberData(widget.userID);

      setState(() {
        if (cSnapshot != null) {
          _name = cSnapshot.memberDetails['fullName'];
        } else if (mSnapshot != null) {
          _name = mSnapshot.memberDetails['fullName'];
        }
      });
    } catch (error) {
      print('Failed to fetch user data: $error');
    }
  }

  Future<void> _fetchPresenceStatus() async {
    try {
      PresenceDB? pSnapshot = await getPresenceDB(
        widget.famLegacyID,
        widget.eventID,
        widget.userID,
      );

      if (pSnapshot != null) {
        setState(() {
          _pSnapshot = pSnapshot;
          _presenceStatus = pSnapshot.presenceStatus;
        });
      }
    } catch (error) {
      print('Failed to fetch presence status: $error');
    }
  }

  Future<void> _updatePresenceStatus(String presenceStatus) async {
    try {
      if (_pSnapshot != null) {
        await updatePresenceStatus(
          widget.famLegacyID,
          widget.eventID,
          widget.userID,
          _name,
          presenceStatus,
        );
      } else {
        await createPresenceStatus(
          widget.famLegacyID,
          widget.eventID,
          widget.userID,
          _name,
          presenceStatus,
        );
      }

      setState(() {
        _presenceStatus = presenceStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presence status updated successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Failed to update presence status: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update presence status.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color ableToPresentColor =
        _presenceStatus == 'Able to present' ? Colors.green : Colors.black;
    Color notAbleToPresentColor =
        _presenceStatus == 'Not able to present' ? Colors.green : Colors.black;

    return Row(
      children: [
        TextButton(
          onPressed: () {
            _updatePresenceStatus('Able to present');
          },
          child: Text(
            'Able to present',
            style: TextStyle(color: ableToPresentColor),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        TextButton(
          onPressed: () {
            _updatePresenceStatus('Not able to present');
          },
          child: Text(
            'Not able to present',
            style: TextStyle(color: notAbleToPresentColor),
          ),
        ),
      ],
    );
  }
}
