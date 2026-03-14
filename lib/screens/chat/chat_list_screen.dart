import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'id': '1',
        'name': 'Rajesh Kumar',
        'lastMessage': 'The latest graphene report is ready for revi...',
        'time': '10:45 AM',
        'isOnline': true,
        'emoji': '👨‍💼',
        'status': null,
      },
      {
        'id': '2',
        'name': 'Production Team',
        'lastMessage': 'Meeting scheduled for 2 PM today in the lab.',
        'time': '9:15 AM',
        'isOnline': false,
        'emoji': '🏭',
        'status': null,
      },
      {
        'id': '3',
        'name': 'Dr. Ananya Sharma',
        'lastMessage': 'The conductivity tests are promising!',
        'time': 'Yesterday',
        'isOnline': false,
        'emoji': '👩‍🔬',
        'status': 'read',
      },
      {
        'id': '4',
        'name': 'Mumbai Supply Chain',
        'lastMessage': 'Shipment has arrived at port.',
        'time': 'Tuesday',
        'isOnline': false,
        'emoji': '👥',
        'status': null,
        'sender': 'Amit',
      },
      {
        'id': '5',
        'name': 'Vikram Singh',
        'lastMessage': 'I\'ll send the invoice by EOD.',
        'time': 'Monday',
        'isOnline': false,
        'emoji': '👨‍💼',
        'status': 'sent',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
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
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatTile(context, chat);
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat) {
    return InkWell(
      onTap: () => context.push('/chat/${chat['id']}', extra: chat['name']),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFF0F0F0),
                  child: Text(chat['emoji'], style: const TextStyle(fontSize: 28)),
                ),
                if (chat['isOnline'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          color: chat['time'] == '10:45 AM' || chat['time'] == '9:15 AM'
                              ? const Color(0xFF237227)
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat['status'] == 'read')
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.done_all, size: 16, color: Colors.blue),
                        )
                      else if (chat['status'] == 'sent')
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.done, size: 16, color: Colors.grey),
                        ),
                      if (chat['sender'] != null)
                        Text(
                          '${chat['sender']}: ',
                          style: const TextStyle(
                            color: Color(0xFF237227),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          style: const TextStyle(
                            color: Colors.grey,
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
