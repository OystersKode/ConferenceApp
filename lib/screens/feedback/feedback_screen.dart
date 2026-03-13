import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Feedback'),
      body: Center(child: Text('Feedback Content')),
    );
  }
}
