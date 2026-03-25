import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String userId;
  final String userName;
  final String role;
  final int ratingOverall;
  final int ratingTechnicalContent;
  final int ratingOrganization;
  final int ratingHospitality;
  final int ratingNetworking;
  final String comments;
  final DateTime submittedAt;

  FeedbackModel({
    required this.userId,
    required this.userName,
    required this.role,
    required this.ratingOverall,
    required this.ratingTechnicalContent,
    required this.ratingOrganization,
    required this.ratingHospitality,
    required this.ratingNetworking,
    required this.comments,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'role': role,
      'ratingOverall': ratingOverall,
      'ratingTechnicalContent': ratingTechnicalContent,
      'ratingOrganization': ratingOrganization,
      'ratingHospitality': ratingHospitality,
      'ratingNetworking': ratingNetworking,
      'comments': comments,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      role: map['role'] ?? '',
      ratingOverall: map['ratingOverall'] ?? 0,
      ratingTechnicalContent: map['ratingTechnicalContent'] ?? 0,
      ratingOrganization: map['ratingOrganization'] ?? 0,
      ratingHospitality: map['ratingHospitality'] ?? 0,
      ratingNetworking: map['ratingNetworking'] ?? 0,
      comments: map['comments'] ?? '',
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
    );
  }
}
