import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/signup_request_model.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Approve a signup request
  Future<void> approveRequest(SignupRequestModel request) async {
    try {
      // 1. Generate User ID
      String generatedUserId = await _generateUserId(request.role);

      // 2. Update the user document status and assigned ID
      await _firestore.collection('users').doc(request.id).update({
        'status': 'approved',
        'userId': generatedUserId,
      });

      // 3. Update the signup request status
      await _firestore.collection('signup_requests').doc(request.id).update({
        'status': 'approved',
      });
      
      // In a real app, you'd trigger an email notification here (e.g., via Cloud Functions)
    } catch (e) {
      print('Error approving request: $e');
      rethrow;
    }
  }

  Future<void> rejectRequest(String requestId) async {
    // Update user status to rejected
    await _firestore.collection('users').doc(requestId).update({
      'status': 'rejected',
    });
    
    // Update signup request status
    await _firestore.collection('signup_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  Future<String> _generateUserId(String role) async {
    String roleCode = role.toLowerCase() == 'presenter' ? 'PR' : 'DG';
    String prefix = 'ICS26$roleCode-';
    
    // Get all users with this role to find the next number
    // Note: In a high-concurrency app, this should be done with a counter document or transaction
    final querySnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .where('status', isEqualTo: 'approved')
        .get();

    int nextNumber = querySnapshot.docs.length + 1;
    return '$prefix${nextNumber.toString().padLeft(3, '0')}';
  }
}
