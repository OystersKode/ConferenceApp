import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ICSmartConferenceApp(),
    ),
  );
}

class ICSmartConferenceApp extends StatelessWidget {
  const ICSmartConferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IC SMART Conference 2K26',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Scaffold(
          body: child,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('test').add({
                'name': 'Sumit',
                'project': 'Conference App',
                'timestamp': FieldValue.serverTimestamp(),
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test data added to Firestore!')),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
