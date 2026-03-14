import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // Sessions related
  Stream<List<SessionModel>> getSessions(String date) {
    return _db
        .collection('sessions')
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SessionModel.fromMap(doc.data(), doc.id))
            .toList());
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
