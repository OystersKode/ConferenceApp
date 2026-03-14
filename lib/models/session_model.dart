import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String title;
  final String speaker;
  final String location;
  final String time;
  final String date;
  final String track;

  SessionModel({
    required this.id,
    required this.title,
    required this.speaker,
    required this.location,
    required this.time,
    required this.date,
    required this.track,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      title: map['title'] ?? '',
      speaker: map['speaker'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      track: map['track'] ?? '',
    );
  }
}
