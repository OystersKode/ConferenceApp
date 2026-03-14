import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicalSessionModel {
  final String id;
  final String title;
  final int sessionNumber;
  final String mode; // online, offline, hybrid
  final String startTime;
  final String endTime;
  final String venue;
  final List<String> chairs;
  final int displayOrder;

  TechnicalSessionModel({
    required this.id,
    required this.title,
    required this.sessionNumber,
    required this.mode,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.chairs,
    required this.displayOrder,
  });

  factory TechnicalSessionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TechnicalSessionModel(
      id: doc.id,
      title: data['title'] ?? '',
      sessionNumber: data['sessionNumber'] ?? 0,
      mode: data['mode'] ?? 'offline',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      venue: data['venue'] ?? '',
      chairs: List<String>.from(data['chairs'] ?? []),
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'sessionNumber': sessionNumber,
      'mode': mode,
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'chairs': chairs,
      'displayOrder': displayOrder,
    };
  }
}
