import 'package:cloud_firestore/cloud_firestore.dart';

class KeynoteModel {
  final String id;
  final String speaker;
  final String title;
  final String startTime;
  final String endTime;
  final int sessionNumber;

  KeynoteModel({
    required this.id,
    required this.speaker,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.sessionNumber,
  });

  factory KeynoteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KeynoteModel(
      id: doc.id,
      speaker: data['speaker'] ?? '',
      title: data['title'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      sessionNumber: data['sessionNumber'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speaker': speaker,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'sessionNumber': sessionNumber,
    };
  }
}
