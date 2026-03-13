import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Appointments'),
      body: Center(child: Text('Appointments Content')),
    );
  }
}
