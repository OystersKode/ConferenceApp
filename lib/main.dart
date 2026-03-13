import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
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
    );
  }
}
