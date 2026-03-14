import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
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
import '../screens/profile/profile_setup_screen.dart';
import '../screens/speakers/speakers_screen.dart';
import '../screens/presenters/presenters_screen.dart';
import '../screens/sponsors/sponsors_screen.dart';
import '../screens/organisers/organisers_screen.dart';
import '../screens/ppt_download/ppt_download_screen.dart';
import '../screens/admin/admin_approval_screen.dart';
import '../screens/splash_screen.dart';
import '../providers/auth_provider.dart';

class AppRouter {
  static GoRouter getRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final bool initialized = authProvider.isInitialized;
        final bool loggedIn = authProvider.isAuthenticated;
        final bool isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        final bool isSplash = state.matchedLocation == '/splash';

        // 1. While the app is initializing (checking Firebase session), stay on Splash
        if (!initialized) return '/splash';

        // 2. If at Splash and initialized, decide where to go
        if (isSplash) {
          if (!loggedIn) return '/login';
          // If logged in, we must check the profile before going to '/'
          if (authProvider.userModel == null) return null; // Stay on splash until user model is fetched
          if (!authProvider.userModel!.profileComplete) return '/profile-setup';
          return '/';
        }

        // 3. Not logged in -> Redirect to Login (unless already on an Auth route)
        if (!loggedIn) {
          return isAuthRoute ? null : '/login';
        }

        // 4. Logged in, but user data is still being fetched from Firestore
        if (authProvider.userModel == null) {
          // Stay on the current screen or show splash if we were at root
          return state.matchedLocation == '/' ? '/splash' : null;
        }

        // 5. Force Profile Setup if incomplete
        if (!authProvider.userModel!.profileComplete && 
            state.matchedLocation != '/profile-setup' &&
            state.matchedLocation != '/admin-approval') {
          return '/profile-setup';
        }

        // 6. If profile is complete, don't allow access to Auth or Setup screens
        if (authProvider.userModel!.profileComplete && 
            (isAuthRoute || state.matchedLocation == '/profile-setup')) {
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
        GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
        GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
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
        GoRoute(path: '/presenters', builder: (context, state) => const PresentersScreen()),
        GoRoute(path: '/sponsors', builder: (context, state) => const SponsorsScreen()),
        GoRoute(path: '/organisers', builder: (context, state) => const OrganisersScreen()),
        GoRoute(path: '/ppt-download', builder: (context, state) => const PPTDownloadScreen()),
      ],
    );
  }
}
