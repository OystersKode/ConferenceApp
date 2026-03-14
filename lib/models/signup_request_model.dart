import 'package:cloud_firestore/cloud_firestore.dart';

class SignupRequestModel {
  final String id;
  final String name;
  final String email;
  final String role; // presenter, delegate
  final String? paperTitle; // for presenters
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  SignupRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.paperTitle,
    required this.status,
    required this.createdAt,
  });

  factory SignupRequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SignupRequestModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'delegate',
      paperTitle: data['paperTitle'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (paperTitle != null) 'paperTitle': paperTitle,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
