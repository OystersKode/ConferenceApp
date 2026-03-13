import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class PPTDownloadScreen extends StatelessWidget {
  const PPTDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'PPT Download'),
      body: Center(child: Text('PPT Download Content')),
    );
  }
}
