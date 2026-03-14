import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String uid;
  final String name;
  final String role; // super_admin, admin

  AdminModel({
    required this.uid,
    required this.name,
    required this.role,
  });

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      uid: doc.id,
      name: data['name'] ?? '',
      role: data['role'] ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
    };
  }
}
