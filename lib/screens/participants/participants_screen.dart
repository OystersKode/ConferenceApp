import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Participants'),
      body: Center(child: Text('Participants Content')),
    );
  }
}
