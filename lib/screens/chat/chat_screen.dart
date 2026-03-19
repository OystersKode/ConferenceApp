import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/bottom_navbar.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (currentUser == null) return;

    final message = MessageModel(
      id: '', 
      senderId: currentUser.uid,
      receiverId: '', 
      message: text,
      timestamp: DateTime.now(),
    );

    _messageController.clear();
    await _chatService.sendMessage(widget.chatId, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.chatName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Start your conversation!',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  );
                }

                final messages = snapshot.data!;
                final currentUserId = Provider.of<AuthProvider>(context).userModel?.uid;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length + 1, // Add 1 for the bottom spacing
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const SizedBox(height: 100); // Space for floating navbar at the bottom (since list is reversed)
                    }
                    final msg = messages[index - 1];
                    final isMe = msg.senderId == currentUserId;
                    
                    bool showDate = (index - 1) == messages.length - 1 || 
                        messages[index - 1].timestamp.day != messages[index].timestamp.day;

                    return Column(
                      children: [
                        if (showDate) _buildDateChip(msg.timestamp),
                        _buildMessageBubble(msg, isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildDateChip(DateTime date) {
    String dateStr = 'TODAY';
    final now = DateTime.now();
    if (now.year == date.year && now.month == date.month && now.day - date.day == 1) {
      dateStr = 'YESTERDAY';
    } else if (now.year != date.year || now.month != date.month || now.day != date.day) {
      dateStr = DateFormat('MMMM d').format(date).toUpperCase();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDE6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            dateStr,
            style: const TextStyle(color: Color(0xFFFF6D3B), fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF56945A) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.message,
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('jm').format(msg.timestamp),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: Color(0xFF56945A)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF133B15), 
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E4D2F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF2E4D2F),
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
