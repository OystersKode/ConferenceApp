import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class QAScreen extends StatelessWidget {
  const QAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Q&A'),
      body: Center(child: Text('Q&A Content')),
    );
  }
}
