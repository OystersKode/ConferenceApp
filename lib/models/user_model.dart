import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // Firebase Auth UID
  final String userId; // Generated ID: ICS26PR-001
  final String role; // presenter, delegate
  final String status; // pending, approved, rejected
  final String name;
  final String email;
  final String profilePhoto;
  final String about;
  final String phone;
  final String country;
  final String designation;
  final String organization;
  final String? paperTitle; // For presenters
  final List<String> correspondingAuthors; // For presenters
  final bool feedbackSubmitted;
  final bool profileComplete;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.userId,
    required this.role,
    required this.status,
    required this.name,
    required this.email,
    this.profilePhoto = '',
    this.about = '',
    this.phone = '',
    this.country = '',
    this.designation = '',
    this.organization = '',
    this.paperTitle,
    this.correspondingAuthors = const [],
    this.feedbackSubmitted = false,
    this.profileComplete = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      userId: map['userId'] ?? '',
      role: map['role'] ?? 'delegate',
      status: map['status'] ?? 'pending',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      about: map['about'] ?? '',
      phone: map['phone'] ?? '',
      country: map['country'] ?? '',
      designation: map['designation'] ?? '',
      organization: map['organization'] ?? '',
      paperTitle: map['paperTitle'],
      correspondingAuthors: List<String>.from(map['correspondingAuthors'] ?? []),
      feedbackSubmitted: map['feedbackSubmitted'] ?? false,
      profileComplete: map['profileComplete'] ?? false,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'role': role,
      'status': status,
      'name': name,
      'email': email,
      'profilePhoto': profilePhoto,
      'about': about,
      'phone': phone,
      'country': country,
      'designation': designation,
      'organization': organization,
      'paperTitle': paperTitle,
      'correspondingAuthors': correspondingAuthors,
      'feedbackSubmitted': feedbackSubmitted,
      'profileComplete': profileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
