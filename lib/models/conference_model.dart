import 'package:cloud_firestore/cloud_firestore.dart';

class ConferenceModel {
  final String id;
  final String name;
  final String shortName;
  final int year;
  final String startDate;
  final String endDate;
  final String location;
  final String city;
  final String country;

  ConferenceModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.city,
    required this.country,
  });

  factory ConferenceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ConferenceModel(
      id: doc.id,
      name: data['name'] ?? '',
      shortName: data['shortName'] ?? '',
      year: data['year'] ?? 2026,
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      location: data['location'] ?? '',
      city: data['city'] ?? '',
      country: data['country'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'shortName': shortName,
      'year': year,
      'startDate': startDate,
      'endDate': endDate,
      'location': location,
      'city': city,
      'country': country,
    };
  }
}
