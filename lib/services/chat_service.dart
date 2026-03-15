import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get existing conversation
  Future<String> getOrCreateConversation(String currentUserId, String otherUserId) async {
    // Check for existing conversation with these participants
    final query = await _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in query.docs) {
      List participants = doc['participants'];
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // If no existing conversation, create a new one
    final docRef = await _firestore.collection('conversations').add({
      'participants': [currentUserId, otherUserId],
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Get list of conversations for a user
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList());
  }

  // Get messages for a conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Send message
  Future<void> sendMessage(String conversationId, MessageModel message) async {
    // Add message to subcollection
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add(message.toMap());

    // Update last message in conversation
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': message.message,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
