// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_famlegacy/event_files/databases/event_db.dart';

class CreateEvent extends StatefulWidget {
  final String userID, famLegacyID, createBy;

  const CreateEvent({
    Key? key,
    required this.userID,
    required this.famLegacyID,
    required this.createBy,
  }) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameCont = TextEditingController();
  final TextEditingController _eventLocationCont = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final double _heightSize = 38;

  @override
  void dispose() {
    _eventNameCont.dispose();
    _eventLocationCont.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void createEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date')),
        );
        return;
      }
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time')),
        );
        return;
      }

      String eventName = _eventNameCont.text;
      DateTime eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      String eventLocation = _eventLocationCont.text;

      await createEventNotification(
        widget.famLegacyID,
        eventName,
        DateFormat('HH:mm').format(eventDateTime),
        Timestamp.fromDate(eventDateTime),
        eventLocation,
        widget.createBy,
        widget.userID,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: _heightSize),
              TextFormField(
                controller: _eventNameCont,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Event Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              SizedBox(height: _heightSize),
              ElevatedButton(
                onPressed: _selectDate,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : 'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                ),
              ),
              SizedBox(height: _heightSize),
              ElevatedButton(
                onPressed: _selectTime,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: Text(
                  _selectedTime == null
                      ? 'Select Time'
                      : 'Time: ${_selectedTime!.format(context)}',
                ),
              ),
              SizedBox(height: _heightSize),
              TextFormField(
                controller: _eventLocationCont,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Event Location',
                  hintText: 'Enter the event location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event location';
                  }
                  return null;
                },
              ),
              SizedBox(height: _heightSize),
              ElevatedButton(
                onPressed: createEvent,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
