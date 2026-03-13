import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Event Details'),
      body: Center(child: Text('Event Details Content')),
    );
  }
}
