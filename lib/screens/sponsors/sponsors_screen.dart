import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class SponsorsScreen extends StatelessWidget {
  const SponsorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Sponsors'),
      body: Center(child: Text('Sponsors Content')),
    );
  }
}
