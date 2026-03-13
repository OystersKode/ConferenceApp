import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class CommitteesScreen extends StatelessWidget {
  const CommitteesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Committees'),
      body: Center(child: Text('Committees Content')),
    );
  }
}
