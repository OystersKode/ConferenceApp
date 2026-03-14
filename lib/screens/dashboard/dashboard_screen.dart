import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_header.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Event Details', 'icon': Icons.info, 'route': AppRoutes.eventDetails},
      {'title': 'Speakers', 'icon': Icons.people, 'route': AppRoutes.speakers},
      {'title': 'Program Schedule', 'icon': Icons.calendar_today, 'route': AppRoutes.schedule},
      {'title': 'Participants', 'icon': Icons.person, 'route': AppRoutes.participants},
      {'title': 'Sponsors', 'icon': Icons.business, 'route': AppRoutes.sponsors},
      {'title': 'Organisers', 'icon': Icons.corporate_fare, 'route': AppRoutes.organisers},
      {'title': 'Committees', 'icon': Icons.group, 'route': AppRoutes.committees},
      {'title': 'Chat', 'icon': Icons.chat, 'route': AppRoutes.chat},
      {'title': 'Appointments', 'icon': Icons.book_online, 'route': AppRoutes.appointments},
      {'title': 'Q&A', 'icon': Icons.question_answer, 'route': AppRoutes.qa},
      {'title': 'PPT Download', 'icon': Icons.download, 'route': AppRoutes.pptDownload},
      {'title': 'Feedback', 'icon': Icons.feedback, 'route': AppRoutes.feedback},
      {'title': 'Support', 'icon': Icons.support_agent, 'route': AppRoutes.support},
    ];

    return Scaffold(
      appBar: const AppHeader(title: 'IC SMART Conference 2K26'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return DashboardCard(
              title: item['title'],
              icon: item['icon'],
              onTap: () => Navigator.pushNamed(context, item['route']),
            );
          },
        ),
      ),
    );
  }
}

class AppRoutes {
}
