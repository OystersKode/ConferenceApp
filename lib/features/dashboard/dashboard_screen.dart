import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'widgets/header.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/Conference_Partners_section.dart';
import '../../widgets/bottom_navbar.dart';
import '../drawer/sidebar_menu.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/technical_session_model.dart';
import '../../models/day_model.dart';
import '../../core/constants/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final isPresenter = user?.role == 'presenter';

    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Feedback', 'icon': 'assets/FinalIconss/Feedback.jpg', 'route': '/feedback'},
      {'title': 'Event Details', 'icon': 'assets/FinalIconss/Event_Details.jpg', 'route': '/event-details'},
      {'title': 'Program Schedule', 'icon': 'assets/FinalIconss/Program_Schedule.jpg', 'route': '/schedule'},
      {'title': 'Speakers', 'icon': 'assets/FinalIconss/Speakers.jpg', 'route': '/speakers'},
      {'title': 'Participants', 'icon': 'assets/FinalIconss/Presenters.jpg', 'route': '/participants'},
      {'title': 'Associate Partners', 'icon': 'assets/FinalIconss/Sponsers.jpg', 'route': '/sponsors'},
      {'title': 'Committees', 'icon': 'assets/FinalIconss/Comitees.jpg', 'route': '/committee'},
      {'title': 'Chat', 'icon': 'assets/FinalIconss/Chat.jpg', 'route': '/chat'},
      {'title': 'PPT Download', 'icon': 'assets/FinalIconss/PPT.jpg', 'route': '/ppt-download'},
      {'title': 'Support', 'icon': 'assets/FinalIconss/Support.jpg', 'route': '/support'},
    ];

    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: const Color(0xFFF8FAF8), // Very light green background
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            
            // NEW: Allocated Session Section (Just below image header)
            if (isPresenter && user != null) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'ALLOCATED SESSION',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildPresenterSessionCard(context, user.uid, user.linkedPaperPath),
            ],

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

  Widget _buildPresenterSessionCard(BuildContext context, String uid, String? paperPath) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService().getPresenterPresentation(uid, paperPath: paperPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          ));
        }
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();

        final session = snapshot.data!['session'] as TechnicalSessionModel;
        final day = snapshot.data!['day'] as DayModel;

        return GestureDetector(
          onTap: () => context.push('/session-details/${day.id}', extra: session),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.play_lesson_outlined, color: Color(0xFF2E7D32), size: 24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session ${session.sessionNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(Icons.calendar_today_outlined, 'Day ${day.dayNumber == 1 ? "I" : day.dayNumber == 2 ? "II" : day.dayNumber}'),
                    _buildInfoItem(Icons.access_time_outlined, session.startTime),
                    _buildInfoItem(Icons.location_on_outlined, session.venue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
