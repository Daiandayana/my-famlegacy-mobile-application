// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp? timestamp) {
  if (timestamp != null) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
  return 'Loading...';
}

int calculateAge(Timestamp birthDate) {
  DateTime currentDate = DateTime.now();
  DateTime birthDateTime = birthDate.toDate();
  int age = currentDate.year - birthDateTime.year;
  if (currentDate.month < birthDateTime.month ||
      (currentDate.month == birthDateTime.month &&
          currentDate.day < birthDateTime.day)) {
    age--;
  }
  return age;
}

int calculateAgeWithDeath(Timestamp birthDate, Timestamp deathDate) {
  DateTime currentDate = DateTime.now();
  DateTime birthDateTime = birthDate.toDate();

  int age;

  DateTime deathDateTime = deathDate.toDate();
  age = deathDateTime.year - birthDateTime.year;

  if (currentDate.isBefore(deathDateTime)) {
    age--;
  }

  return age;
}

void deleteUserWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user != null) {
      await user.delete();
      print('User deleted successfully.');
    } else {
      print('User not found.');
    }
  } catch (e) {
    print('Failed to delete user: $e');
  }
}
