import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceModel {
  final String id;
  final String title;
  final String fileUrl;
  final String type; // 'ppt', 'pdf', etc.
  final String sessionId;
  final String uploadedBy;

  ResourceModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.type,
    required this.sessionId,
    required this.uploadedBy,
  });

  factory ResourceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ResourceModel(
      id: doc.id,
      title: data['title'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      type: data['type'] ?? 'ppt',
      sessionId: data['sessionId'] ?? '',
      uploadedBy: data['uploadedBy'] ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fileUrl': fileUrl,
      'type': type,
      'sessionId': sessionId,
      'uploadedBy': uploadedBy,
    };
  }
}
