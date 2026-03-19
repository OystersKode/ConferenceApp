import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/schedule/session_details_screen.dart';
import '../screens/committees/committees_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/support/support_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../features/profile/profile_screen.dart';
import '../screens/profile/digital_id_screen.dart';
import '../screens/profile/profile_setup_screen.dart';
import '../screens/speakers/speakers_screen.dart';
import '../screens/participants/participants_screen.dart';
import '../screens/sponsors/sponsors_screen.dart';
import '../screens/organisers/organisers_screen.dart';
import '../screens/ppt_download/ppt_download_screen.dart';
import '../screens/admin/admin_approval_screen.dart';
import '../screens/admin/seeder_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/event_details/event_details_screen.dart';
import '../screens/support/app_developer_screen.dart';
import '../providers/auth_provider.dart';
import '../models/technical_session_model.dart';

class AppRouter {
  static GoRouter getRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool initialized = authProvider.isInitialized;
        final bool loggedIn = authProvider.isAuthenticated;
        
        final String location = state.uri.path;
        
        if (!initialized) return '/splash';

        // CRITICAL FIX: Explicitly check for signup first. 
        // This prevents the redirect from triggering while we are on the signup page.
        if (location == '/signup') {
          return null;
        }

        if (location == '/splash') {
          if (!loggedIn) return '/login';
          if (authProvider.userModel == null) return null;
          if (!authProvider.userModel!.profileComplete) return '/profile-setup';
          return '/';
        }

        if (!loggedIn) {
          return location == '/signup' ? null : '/login';
        }

        if (authProvider.userModel == null) {
          // If logged in (authenticating) but model not yet loaded, 
          // allow staying on signup if that's where we are.
          if (location == '/signup') return null;
          return location == '/' ? '/splash' : null;
        }

        if (!authProvider.userModel!.profileComplete && 
            location != '/profile-setup' &&
            location != '/admin-approval' &&
            location != '/admin-seeder') {
          return '/profile-setup';
        }

        if (authProvider.userModel!.profileComplete && 
            (location == '/login' || location == '/signup' || location == '/profile-setup')) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),
        GoRoute(path: '/admin-approval', builder: (context, state) => const AdminApprovalScreen()),
        GoRoute(path: '/admin-seeder', builder: (context, state) => const SeederScreen()),
        GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
        GoRoute(path: '/event-details', builder: (context, state) => const EventDetailsScreen()),
        
        GoRoute(
          path: '/session-details/:dayId',
          builder: (context, state) {
            final dayId = state.pathParameters['dayId']!;
            final session = state.extra as TechnicalSessionModel;
            return SessionDetailsScreen(dayId: dayId, session: session);
          },
        ),

        GoRoute(path: '/committee', builder: (context, state) => const CommitteesScreen()),
        GoRoute(path: '/chat', builder: (context, state) => const ChatListScreen()),
        GoRoute(path: '/chat/:id', builder: (context, state) => ChatScreen(
          chatId: state.pathParameters['id']!,
          chatName: state.extra as String? ?? 'Chat',
        )),
        GoRoute(path: '/support', builder: (context, state) => const SupportScreen()),
        GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/digital-id', builder: (context, state) => const DigitalIdScreen()),
        GoRoute(path: '/speakers', builder: (context, state) => const SpeakersScreen()),
        GoRoute(path: '/participants', builder: (context, state) => const ParticipantsScreen()),
        GoRoute(path: '/sponsors', builder: (context, state) => const SponsorsScreen()),
        GoRoute(path: '/organisers', builder: (context, state) => const OrganisersScreen()),
        GoRoute(path: '/ppt-download', builder: (context, state) => const PPTDownloadScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
        GoRoute(path: '/app-developer', builder: (context, state) => const AppDeveloperScreen()),
      ],
    );
  }
}
