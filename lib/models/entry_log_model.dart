import 'package:cloud_firestore/cloud_firestore.dart';

class EntryLogModel {
  final String userId;
  final DateTime timestamp;
  final String gate;

  EntryLogModel({
    required this.userId,
    required this.timestamp,
    required this.gate,
  });

  factory EntryLogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EntryLogModel(
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      gate: data['gate'] ?? 'main_gate',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
      'gate': gate,
    };
  }
}
