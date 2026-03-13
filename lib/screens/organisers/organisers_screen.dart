import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class OrganisersScreen extends StatelessWidget {
  const OrganisersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Organisers'),
      body: Center(child: Text('Organisers Content')),
    );
  }
}
