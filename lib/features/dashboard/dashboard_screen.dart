import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/header.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/organizer_section.dart';
import '../../widgets/bottom_navbar.dart';
import '../drawer/sidebar_menu.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Exact mapping based on your assets/FinalIconss folder content (JPG files)
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Feedback', 'icon': 'assets/FinalIconss/Feedback.jpg', 'route': '/feedback'},
      {'title': 'Event Details', 'icon': 'assets/FinalIconss/Event_Details.jpg', 'route': '/event-details'},
      {'title': 'Program Schedule', 'icon': 'assets/FinalIconss/Program_Schedule.jpg', 'route': '/schedule'},
      {'title': 'Speakers', 'icon': 'assets/FinalIconss/Speakers.jpg', 'route': '/speakers'},
      {'title': 'Presenters', 'icon': 'assets/FinalIconss/Presenters.jpg', 'route': '/presenters'},
      {'title': 'Associate Sponsers', 'icon': 'assets/FinalIconss/Sponsers.jpg', 'route': '/sponsors'},
      {'title': 'Organizers', 'icon': 'assets/FinalIconss/Organisers.jpg', 'route': '/organisers'},
      {'title': 'Committees', 'icon': 'assets/FinalIconss/Comitees.jpg', 'route': '/committee'},
      {'title': 'Chat', 'icon': 'assets/FinalIconss/Chat.jpg', 'route': '/chat'},
      {'title': 'PPT Download', 'icon': 'assets/FinalIconss/PPT.jpg', 'route': '/ppt-download'},
      {'title': 'Support', 'icon': 'assets/FinalIconss/Support.jpg', 'route': '/support'},
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return FeatureCard(
                    title: menuItems[index]['title'],
                    iconPath: menuItems[index]['icon'],
                    onTap: () => context.push(menuItems[index]['route']),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
