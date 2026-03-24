import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_header.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/technical_session_model.dart';
import '../../models/paper_model.dart';
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
      backgroundColor: const Color(0xFFF1F5F1), // Light greenish background
      appBar: const AppHeader(title: 'IC SMART 2026'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            Container(
              width: double.infinity,
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/banner.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Allocated Session for Presenters
            if (isPresenter && user != null) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'ALLOCATED SESSION',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildPresenterBanner(user.uid, user.linkedPaperPath),
            ],
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPresenterBanner(String uid, String? paperPath) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService().getPresenterPresentation(uid, paperPath: paperPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(16.0),
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
            margin: const EdgeInsets.all(16),
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
                        color: const Color(0xFFE8F5E9),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSmallInfoItem(Icons.calendar_today_outlined, 'Day ${day.dayNumber == 1 ? "I" : day.dayNumber == 2 ? "II" : day.dayNumber}'),
                    _buildSmallInfoItem(Icons.access_time_outlined, session.startTime),
                    _buildSmallInfoItem(Icons.location_on_outlined, session.venue),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmallInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2E7D32), size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
