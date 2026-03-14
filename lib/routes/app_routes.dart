import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/committees/committees_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../features/profile/profile_screen.dart';
import '../screens/profile/digital_id_screen.dart';
import '../screens/speakers/speakers_screen.dart';
import '../screens/presenters/presenters_screen.dart';
import '../screens/sponsors/sponsors_screen.dart';
import '../screens/organisers/organisers_screen.dart';
import '../screens/ppt_download/ppt_download_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser == null ? '/login' : '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: '/committee',
        builder: (context, state) => const CommitteesScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(
          chatId: state.pathParameters['id']!,
          chatName: state.extra as String? ?? 'Chat',
        ),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/digital-id',
        builder: (context, state) => const DigitalIdScreen(),
      ),
      GoRoute(
        path: '/speakers',
        builder: (context, state) => const SpeakersScreen(),
      ),
      GoRoute(
        path: '/presenters',
        builder: (context, state) => const PresentersScreen(),
      ),
      GoRoute(
        path: '/sponsors',
        builder: (context, state) => const SponsorsScreen(),
      ),
      GoRoute(
        path: '/organisers',
        builder: (context, state) => const OrganisersScreen(),
      ),
      GoRoute(
        path: '/ppt-download',
        builder: (context, state) => const PPTDownloadScreen(),
      ),
    ],
  );
}
