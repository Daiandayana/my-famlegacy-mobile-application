// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleDB {
  final String id;
  final String email;
  final String role;

  UserRoleDB({
    required this.id,
    required this.email,
    required this.role,
  });
}

Future deleteUserRole(String email) async {
  try {
    await FirebaseFirestore.instance
        .collection('UserRoles')
        .doc(email)
        .delete();

    print('Success Delete User Role');
  } catch (error) {
    print('Error delete user role: $error');
  }
}

Future<UserRoleDB?> getUserRoleData(String email) async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('UserRoles')
        .doc(email)
        .get();

    if (snapshot.exists) {
      String id = snapshot['id'];
      String email = snapshot['email'];
      String role = snapshot['role'];

      return UserRoleDB(
        id: id,
        email: email,
        role: role,
      );
    }
  } catch (e) {
    print('Failed to get User Role data');
  }
  return null;
}

Future createUserRoleDB(String email, String id, String role) async {
  final userRoleRef =
      FirebaseFirestore.instance.collection('UserRoles').doc(email);

  final userRoleData = {
    'id': id,
    'email': email,
    'role': role,
  };

  try {
    await userRoleRef.set(userRoleData);
    print('Successfully store User Role details into database !');
  } catch (e) {
    print('Failed store User Role details into database: $e');
  }
}
