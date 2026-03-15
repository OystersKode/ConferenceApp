import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../models/user_model.dart';
import '../models/day_model.dart';
import '../models/event_model.dart';
import '../models/technical_session_model.dart';
import '../models/keynote_model.dart';
import '../models/paper_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String conferenceId = 'ic-smart-2026';

  // User related
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Schedule related
  Stream<List<DayModel>> getConferenceDays() {
    return _db
        .collection('conferences')
        .doc(conferenceId)
        .collection('days')
        .orderBy('dayNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DayModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<EventModel>> getDayEvents(String dayId) {
    return _db
        .collection('conferences')
        .doc(conferenceId)
        .collection('days')
        .doc(dayId)
        .collection('events')
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<TechnicalSessionModel>> getDayTechnicalSessions(String dayId) {
    return _db
        .collection('conferences')
        .doc(conferenceId)
        .collection('days')
        .doc(dayId)
        .collection('technical_sessions')
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TechnicalSessionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<KeynoteModel>> getDayKeynotes(String dayId) {
    return _db
        .collection('conferences')
        .doc(conferenceId)
        .collection('days')
        .doc(dayId)
        .collection('keynotes')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => KeynoteModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<PaperModel>> getSessionPapers(String dayId, String sessionId) {
    return _db
        .collection('conferences')
        .doc(conferenceId)
        .collection('days')
        .doc(dayId)
        .collection('technical_sessions')
        .doc(sessionId)
        .collection('papers')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaperModel.fromFirestore(doc))
            .toList());
  }

  /// Helper to safely convert dynamic maps to Map<String, dynamic>
  Map<String, dynamic> _castMap(dynamic map) => Map<String, dynamic>.from(map as Map);

  /// SEEDER FUNCTION: Enhanced to handle all nested data perfectly
  Future<void> seedDatabase(dynamic rawData) async {
    final Map<String, dynamic> data = _castMap(rawData);
    final WriteBatch batch = _db.batch();
    final conferenceRef = _db.collection('conferences').doc(conferenceId);

    dev.log('Seeding: Starting root conference data...');
    batch.set(conferenceRef, _castMap(data['conference']));

    final List daysData = data['days'] ?? [];
    for (var rawDayData in daysData) {
      final dayData = _castMap(rawDayData);
      final String dayId = dayData['id'];
      final dayRef = conferenceRef.collection('days').doc(dayId);
      
      dev.log('Seeding: Processing $dayId...');
      batch.set(dayRef, {
        'title': dayData['title'],
        'date': dayData['date'],
        'dayNumber': dayData['dayNumber'],
      });

      // 1. Process Events
      final List events = dayData['events'] ?? [];
      for (var i = 0; i < events.length; i++) {
        final eventRef = dayRef.collection('events').doc('event-${i + 1}');
        batch.set(eventRef, _castMap(events[i]));
      }

      // 2. Process Keynotes
      final List keynotes = dayData['keynotes'] ?? [];
      for (var i = 0; i < keynotes.length; i++) {
        final keynoteRef = dayRef.collection('keynotes').doc('keynote-${i + 1}');
        batch.set(keynoteRef, _castMap(keynotes[i]));
      }

      // 3. Process Technical Sessions
      final List sessions = dayData['technical_sessions'] ?? [];
      if (sessions.isNotEmpty) {
        // Create a summary event in the main timeline for technical sessions
        final techSummaryRef = dayRef.collection('events').doc('event-tech-sessions');
        batch.set(techSummaryRef, {
          'title': 'Technical Sessions (8 Parallel)',
          'type': 'technical_session',
          'startTime': _castMap(sessions.first)['startTime'],
          'endTime': _castMap(sessions.first)['endTime'],
          'venue': 'Various Rooms (See Details)',
          'displayOrder': 11.5,
        });

        for (var rawSessionData in sessions) {
          final sessionData = _castMap(rawSessionData);
          final String sessionId = sessionData['id'];
          final sessionRef = dayRef.collection('technical_sessions').doc(sessionId);
          
          final List papers = sessionData['papers'] ?? [];
          final sessionToSave = Map<String, dynamic>.from(sessionData)..remove('papers');
          batch.set(sessionRef, sessionToSave);

          // 4. Process Papers subcollection
          for (var i = 0; i < papers.length; i++) {
            final paperRef = sessionRef.collection('papers').doc('paper-${i + 1}');
            batch.set(paperRef, {
              ..._castMap(papers[i]),
              'sessionId': sessionId,
              'status': 'accepted',
            });
          }
        }
      }
    }

    dev.log('Seeding: Committing batch...');
    await batch.commit();
    dev.log('✅ Seeding Complete!');
  }

  // Committee related
  Stream<List<Map<String, dynamic>>> getCommitteeMembers() {
    return _db.collection('committee_members').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Feedback related
  Future<void> submitFeedback(Map<String, dynamic> feedback) async {
    await _db.collection('feedback').add({
      ...feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Chat related
  Stream<List<Map<String, dynamic>>> getChatList(String userId) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
