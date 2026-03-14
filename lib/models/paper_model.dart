import 'package:cloud_firestore/cloud_firestore.dart';

class PaperModel {
  final String id;
  final String title;
  final String presenterId;
  final String sessionId;
  final List<String> correspondingAuthors;
  final String status; // accepted, pending, rejected
  final int? order; // order within a technical session

  PaperModel({
    required this.id,
    required this.title,
    required this.presenterId,
    required this.sessionId,
    required this.correspondingAuthors,
    required this.status,
    this.order,
  });

  factory PaperModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaperModel(
      id: doc.id,
      title: data['title'] ?? '',
      presenterId: data['presenterId'] ?? '',
      sessionId: data['sessionId'] ?? '',
      correspondingAuthors: List<String>.from(data['correspondingAuthors'] ?? []),
      status: data['status'] ?? 'pending',
      order: data['order'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'presenterId': presenterId,
      'sessionId': sessionId,
      'correspondingAuthors': correspondingAuthors,
      'status': status,
      if (order != null) 'order': order,
    };
  }
}
