import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Support'),
      body: Center(child: Text('Support Content')),
    );
  }
}
