import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/conversation_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.userModel?.uid;
    final chatService = ChatService();

    if (currentUserId == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<ConversationModel>>(
        stream: chatService.getConversations(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error: ${snapshot.error}\n\nTip: Check if you need to create a Firestore Index.', 
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No conversations yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            );
          }

          final conversations = snapshot.data!;

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100, indent: 85),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserId = conversation.participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();
                  if (!userSnapshot.data!.exists) return const SizedBox();
                  
                  final otherUser = UserModel.fromMap(userSnapshot.data!.data() as Map<String, dynamic>, otherUserId);

                  return _buildChatTile(context, conversation, otherUser);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ConversationModel chat, UserModel otherUser) {
    String timeStr = DateFormat('jm').format(chat.updatedAt);
    final now = DateTime.now();
    if (now.difference(chat.updatedAt).inDays == 1) {
      timeStr = 'Yesterday';
    } else if (now.difference(chat.updatedAt).inDays > 1) {
      timeStr = DateFormat('EEE').format(chat.updatedAt);
    }

    return InkWell(
      onTap: () => context.push('/chat/${chat.id}', extra: otherUser.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFF0F0F0),
                  backgroundImage: otherUser.profilePhoto.isNotEmpty ? NetworkImage(otherUser.profilePhoto) : null,
                  child: otherUser.profilePhoto.isEmpty ? const Icon(Icons.person, size: 32, color: Colors.grey) : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E), // Online indicator
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUser.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (chat.lastMessage.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: Icon(Icons.done_all, size: 16, color: Color(0xFF3B82F6)),
                        ),
                      Expanded(
                        child: Text(
                          chat.lastMessage.isEmpty ? 'Tap to start chatting' : chat.lastMessage,
                          style: TextStyle(
                            color: chat.lastMessage.isEmpty ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
