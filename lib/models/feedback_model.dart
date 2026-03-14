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

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      role: data['role'] ?? '',
      ratingOverall: data['ratingOverall'] ?? 0,
      ratingOrganization: data['ratingOrganization'] ?? 0,
      ratingTechnicalSessions: data['ratingTechnicalSessions'] ?? 0,
      ratingVenue: data['ratingVenue'] ?? 0,
      ratingCommunication: data['ratingCommunication'] ?? 0,
      comments: data['comments'] ?? '',
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
    );
  }

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
}
