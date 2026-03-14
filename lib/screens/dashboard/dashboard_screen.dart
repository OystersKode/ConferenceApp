import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_header.dart';
import '../../routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Event Details', 'icon': Icons.info, 'route': '/event-details'},
      {'title': 'Speakers', 'icon': Icons.people, 'route': '/speakers'},
      {'title': 'Program Schedule', 'icon': Icons.calendar_today, 'route': '/schedule'},
      {'title': 'Participants', 'icon': Icons.person, 'route': '/participants'},
      {'title': 'Sponsors', 'icon': Icons.business, 'route': '/sponsors'},
      {'title': 'Organisers', 'icon': Icons.corporate_fare, 'route': '/organisers'},
      {'title': 'Committees', 'icon': Icons.group, 'route': '/committees'},
      {'title': 'Chat', 'icon': Icons.chat, 'route': '/chat'},
      {'title': 'Appointments', 'icon': Icons.book_online, 'route': '/appointments'},
      {'title': 'Q&A', 'icon': Icons.question_answer, 'route': '/qa'},
      {'title': 'PPT Download', 'icon': Icons.download, 'route': '/ppt-download'},
      {'title': 'Feedback', 'icon': Icons.feedback, 'route': '/feedback'},
      {'title': 'Support', 'icon': Icons.support_agent, 'route': '/support'},
    ];

    return Scaffold(
      appBar: const AppHeader(title: 'IC SMART 2026'),
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
              onTap: () => context.push(item['route']),
            );
          },
        ),
      ),
    );
  }
}
