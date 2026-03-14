import 'package:flutter/material.dart';
import 'widgets/header.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/organizer_section.dart';
import '../../widgets/bottom_navbar.dart';
import '../drawer/sidebar_menu.dart';
import '../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Feedback', 'icon': Icons.feedback},
      {'title': 'Event Details', 'icon': Icons.info_outline},
      {'title': 'Program Schedule', 'icon': Icons.calendar_today},
      {'title': 'Speakers', 'icon': Icons.people},
      {'title': 'Presenters', 'icon': Icons.mic},
      {'title': 'Sponsors', 'icon': Icons.business},
      {'title': 'Organizers', 'icon': Icons.corporate_fare},
      {'title': 'Committees', 'icon': Icons.group},
      {'title': 'Chat', 'icon': Icons.chat_bubble_outline},
      {'title': 'PPT Download', 'icon': Icons.download},
      {'title': 'Support', 'icon': Icons.support_agent},
    ];

    return Scaffold(
      drawer: const SidebarMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DashboardHeader(),
            const SizedBox(height: 15),
            const OrganizerSection(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return FeatureCard(
                    title: menuItems[index]['title'],
                    icon: menuItems[index]['icon'],
                    onTap: () {},
                  );
                },
              ),
            ),
            const SizedBox(height: 80), // Space for floating navbar
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
