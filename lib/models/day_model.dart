import 'package:cloud_firestore/cloud_firestore.dart';

class DayModel {
  final String id;
  final String title;
  final String date;
  final int dayNumber;

  DayModel({
    required this.id,
    required this.title,
    required this.date,
    required this.dayNumber,
  });

  factory DayModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DayModel(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      dayNumber: data['dayNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'dayNumber': dayNumber,
    };
  }
}
