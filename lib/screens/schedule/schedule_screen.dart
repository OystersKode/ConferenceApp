import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Program Schedule'),
      body: Center(child: Text('Program Schedule Content')),
    );
  }
}
