import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String dateOfBirth;
  final String role;
  final String displayName;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.dateOfBirth,
    required this.role,
    required this.displayName,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      firstName: data['firstName'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      role: data['role'] ?? 'artist',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'dateOfBirth': dateOfBirth,
      'role': role,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}