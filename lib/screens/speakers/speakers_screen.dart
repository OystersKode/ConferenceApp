import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class SpeakersScreen extends StatelessWidget {
  const SpeakersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Speakers'),
      body: Center(child: Text('Speakers Content')),
    );
  }
}
