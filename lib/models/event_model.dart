import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String type; // registration, plenary, keynote, panel, break, lunch, etc.
  final String startTime;
  final String endTime;
  final String venue;
  final num displayOrder; // Changed to num to handle both int and double
  
  // Plenary/Keynote specific fields
  final String? speaker;
  final String? organization;
  final String? country;
  final String? chair;
  final String? moderator;

  // Panel specific fields
  final List<String>? panelists;

  EventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.displayOrder,
    this.speaker,
    this.organization,
    this.country,
    this.chair,
    this.moderator,
    this.panelists,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      venue: data['venue'] ?? '',
      displayOrder: data['displayOrder'] ?? 0,
      speaker: data['speaker'],
      organization: data['organization'],
      country: data['country'],
      chair: data['chair'],
      moderator: data['moderator'],
      panelists: data['panelists'] != null ? List<String>.from(data['panelists']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'displayOrder': displayOrder,
      if (speaker != null) 'speaker': speaker,
      if (organization != null) 'organization': organization,
      if (country != null) 'country': country,
      if (chair != null) 'chair': chair,
      if (moderator != null) 'moderator': moderator,
      if (panelists != null) 'panelists': panelists,
    };
  }
}
