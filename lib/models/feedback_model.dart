import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String userId;
  final String userName;
  final String role;
  final int ratingOverall;
  final int ratingOrganization;
  final int ratingTechnicalSessions;
  final int ratingVenue;
  final int ratingCommunication;
  final String comments;
  final DateTime submittedAt;

  FeedbackModel({
    required this.userId,
    required this.userName,
    required this.role,
    required this.ratingOverall,
    required this.ratingOrganization,
    required this.ratingTechnicalSessions,
    required this.ratingVenue,
    required this.ratingCommunication,
    required this.comments,
    required this.submittedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'role': role,
      'ratingOverall': ratingOverall,
      'ratingOrganization': ratingOrganization,
      'ratingTechnicalSessions': ratingTechnicalSessions,
      'ratingVenue': ratingVenue,
      'ratingCommunication': ratingCommunication,
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
      ratingOrganization: map['ratingOrganization'] ?? 0,
      ratingTechnicalSessions: map['ratingTechnicalSessions'] ?? 0,
      ratingVenue: map['ratingVenue'] ?? 0,
      ratingCommunication: map['ratingCommunication'] ?? 0,
      comments: map['comments'] ?? '',
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
    );
  }
}
