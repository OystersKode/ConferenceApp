import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import '../models/user_model.dart';
import '../models/day_model.dart';
import '../models/event_model.dart';
import '../models/technical_session_model.dart';
import '../models/keynote_model.dart';
import '../models/paper_model.dart';
import '../models/resource_model.dart';
import '../models/notification_model.dart';
import '../models/feedback_model.dart';

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

  Future<void> updateFeedbackStatus(String uid, bool status) async {
    await _db.collection('users').doc(uid).update({'feedbackSubmitted': status});
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

  // NEW: Find presenter's presentation details across all days and sessions
  Future<Map<String, dynamic>?> getPresenterPresentation(String presenterUid) async {
    try {
      final daysSnapshot = await _db
          .collection('conferences')
          .doc(conferenceId)
          .collection('days')
          .get();

      for (var dayDoc in daysSnapshot.docs) {
        final sessionsSnapshot = await dayDoc.reference
            .collection('technical_sessions')
            .get();

        for (var sessionDoc in sessionsSnapshot.docs) {
          final papersSnapshot = await sessionDoc.reference
              .collection('papers')
              .where('presenterId', isEqualTo: presenterUid)
              .get();

          if (papersSnapshot.docs.isNotEmpty) {
            return {
              'paper': PaperModel.fromFirestore(papersSnapshot.docs.first),
              'session': TechnicalSessionModel.fromFirestore(sessionDoc),
              'day': DayModel.fromFirestore(dayDoc),
            };
          }
        }
      }
    } catch (e) {
      dev.log('Error fetching presenter presentation: $e');
    }
    return null;
  }

  // Resources (PPT/PDF) related
  Stream<List<ResourceModel>> getResources() {
    return _db.collection('resources').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ResourceModel.fromFirestore(doc)).toList());
  }

  // Notifications related
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', whereIn: [userId, 'all'])
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        });
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'read': true});
  }

  Future<void> addDemoNotifications(String userId) async {
    final notifications = [
      {
        'userId': userId,
        'title': 'Signup Approved',
        'message': 'Your conference account is approved. Welcome to IC-SMART 2026!',
        'type': 'account',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': userId,
        'title': 'Schedule Updated',
        'message': 'Plenary Talk 04 time has been moved to 12:50 PM.',
        'type': 'schedule_update',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': userId,
        'title': 'Conference Announcement',
        'message': 'Join us for the Cultural Programme at 7:00 PM today.',
        'type': 'announcement',
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var notification in notifications) {
      await _db.collection('notifications').add(notification);
    }
  }

  // Feedback related - Enhanced for atomicity
  Future<void> submitConferenceFeedback(FeedbackModel feedback, String authUid) async {
    final batch = _db.batch();
    
    // 1. Save feedback in conference subcollection
    final feedbackRef = _db
        .collection('conferences')
        .doc(conferenceId)
        .collection('feedback')
        .doc(feedback.userId); 
        
    batch.set(feedbackRef, feedback.toMap());
    
    // 2. Update user profile flag atomatically
    final userRef = _db.collection('users').doc(authUid);
    batch.update(userRef, {'feedbackSubmitted': true});

    await batch.commit();
  }

  /// Helper to safely convert dynamic maps to Map<String, dynamic>
  Map<String, dynamic> _castMap(dynamic map) => Map<String, dynamic>.from(map as Map);

  /// SEEDER FUNCTION
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

  // Legacy Feedback related
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
