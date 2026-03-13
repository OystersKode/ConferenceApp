import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/event_details/event_details_screen.dart';
import '../screens/speakers/speakers_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/participants/participants_screen.dart';
import '../screens/sponsors/sponsors_screen.dart';
import '../screens/organisers/organisers_screen.dart';
import '../screens/committees/committees_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/appointments/appointments_screen.dart';
import '../screens/qa/qa_screen.dart';
import '../screens/ppt_download/ppt_download_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/support/support_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String eventDetails = '/event-details';
  static const String speakers = '/speakers';
  static const String schedule = '/schedule';
  static const String participants = '/participants';
  static const String sponsors = '/sponsors';
  static const String organisers = '/organisers';
  static const String committees = '/committees';
  static const String chat = '/chat';
  static const String appointments = '/appointments';
  static const String qa = '/qa';
  static const String pptDownload = '/ppt-download';
  static const String feedback = '/feedback';
  static const String support = '/support';

  static Map<String, WidgetBuilder> get routes => {
        dashboard: (context) => const DashboardScreen(),
        eventDetails: (context) => const EventDetailsScreen(),
        speakers: (context) => const SpeakersScreen(),
        schedule: (context) => const ScheduleScreen(),
        participants: (context) => const ParticipantsScreen(),
        sponsors: (context) => const SponsorsScreen(),
        organisers: (context) => const OrganisersScreen(),
        committees: (context) => const CommitteesScreen(),
        chat: (context) => const ChatScreen(),
        appointments: (context) => const AppointmentsScreen(),
        qa: (context) => const QAScreen(),
        pptDownload: (context) => const PPTDownloadScreen(),
        feedback: (context) => const FeedbackScreen(),
        support: (context) => const SupportScreen(),
      };
}
