import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/message_model.dart';
import '../../widgets/chat_bubble.dart';

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
  final List<MessageModel> _dummyMessages = [
    MessageModel(
      id: '1',
      senderId: 'other',
      receiverId: 'me',
      message: 'Hello! How are you?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    MessageModel(
      id: '2',
      senderId: 'me',
      receiverId: 'other',
      message: 'I am good, thanks! Are you coming to the conference?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    MessageModel(
      id: '3',
      senderId: 'other',
      receiverId: 'me',
      message: 'Yes, I just registered. See you there!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _dummyMessages.insert(0, MessageModel(
        id: DateTime.now().toString(),
        senderId: 'me',
        receiverId: 'other',
        message: _messageController.text,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text('👤', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Text(widget.chatName),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(15),
              itemCount: _dummyMessages.length,
              itemBuilder: (context, index) {
                final msg = _dummyMessages[index];
                return ChatBubble(
                  message: msg,
                  isMe: msg.senderId == 'me',
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
