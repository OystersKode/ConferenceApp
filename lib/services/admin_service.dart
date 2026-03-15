import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signup_request_model.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String conferenceId = 'ic-smart-2026';

  // Get all pending signup requests
  Stream<List<SignupRequestModel>> getPendingRequests() {
    return _firestore
        .collection('signup_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SignupRequestModel.fromFirestore(doc))
            .toList());
  }

  // Fetch all papers from the schedule to let Admin pick one for a presenter
  Future<List<Map<String, dynamic>>> getAllScheduledPapers() async {
    List<Map<String, dynamic>> allPapers = [];
    
    try {
      // Get all days
      final days = await _firestore
          .collection('conferences')
          .doc(conferenceId)
          .collection('days')
          .get();
      
      for (var day in days.docs) {
        // Get all technical sessions for each day
        final sessions = await day.reference.collection('technical_sessions').get();
        
        for (var session in sessions.docs) {
          // Get all papers for each session
          final papers = await session.reference.collection('papers').get();
          
          for (var paper in papers.docs) {
            allPapers.add({
              'paperId': paper.id,
              'title': paper.get('title') ?? 'Untitled Paper',
              'sessionId': session.id,
              'dayId': day.id,
              'sessionTitle': session.get('title') ?? 'General Session',
              'venue': session.get('venue') ?? 'TBD',
              'time': session.get('startTime') ?? '',
              'paperPath': paper.reference.path, // Store full path for easy updating
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching scheduled papers: $e');
    }
    return allPapers;
  }

  // Professional Approve: Link the selected paper to the presenter
  Future<void> approveAndLinkPresenter({
    required SignupRequestModel request,
    required String paperPath,
  }) async {
    try {
      // 1. Generate User ID (ICS...)
      String generatedUserId = await _generateUserId(request.role);

      // 2. Link the Paper to the User UID in the schedule
      await _firestore.doc(paperPath).update({
        'presenterId': request.id,
      });

      // 3. Update the user document status and assigned ID
      await _firestore.collection('users').doc(request.id).update({
        'status': 'approved',
        'userId': generatedUserId,
      });

      // 4. Update the signup request status
      await _firestore.collection('signup_requests').doc(request.id).update({
        'status': 'approved',
      });
      
    } catch (e) {
      print('Error in approveAndLinkPresenter: $e');
      rethrow;
    }
  }

  // Standard Approve (for Delegates or if no paper link is needed)
  Future<void> approveRequest(SignupRequestModel request) async {
    try {
      String generatedUserId = await _generateUserId(request.role);

      await _firestore.collection('users').doc(request.id).update({
        'status': 'approved',
        'userId': generatedUserId,
      });

      await _firestore.collection('signup_requests').doc(request.id).update({
        'status': 'approved',
      });
    } catch (e) {
      print('Error approving request: $e');
      rethrow;
    }
  }

  Future<void> rejectRequest(String requestId) async {
    await _firestore.collection('users').doc(requestId).update({
      'status': 'rejected',
    });
    
    await _firestore.collection('signup_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  Future<String> _generateUserId(String role) async {
    String roleCode = role.toLowerCase() == 'presenter' ? 'PR' : 'DG';
    String prefix = 'ICS26$roleCode-';
    
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .where('status', isEqualTo: 'approved')
        .get();

    int nextNumber = querySnapshot.docs.length + 1;
    return '$prefix${nextNumber.toString().padLeft(3, '0')}';
  }
}
