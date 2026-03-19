import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';
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

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class ICSmartConferenceApp extends StatefulWidget {
  const ICSmartConferenceApp({super.key});

  @override
  State<ICSmartConferenceApp> createState() => _ICSmartConferenceAppState();
}

class _ICSmartConferenceAppState extends State<ICSmartConferenceApp> {
  late GoRouter _router;
  bool _routerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routerInitialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _router = AppRouter.getRouter(authProvider);
      _routerInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IC-SMART 2026',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      scaffoldMessengerKey: scaffoldMessengerKey,
    );
  }
}
