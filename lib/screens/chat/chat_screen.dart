import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Chat'),
      body: Center(child: Text('Chat Content')),
    );
  }
}
