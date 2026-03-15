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
      appBar: const AppHeader(title: 'IC SMART 2026'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPresenter && user != null) _buildPresenterBanner(user.uid),
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

  Widget _buildPresenterBanner(String uid) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService().getPresenterPresentation(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();

        final paper = snapshot.data!['paper'] as PaperModel;
        final session = snapshot.data!['session'] as TechnicalSessionModel;
        final day = snapshot.data!['day'] as DayModel;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.mic_external_on, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'MY PRESENTATION',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                paper.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 15),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(Icons.calendar_today, day.title),
                  _buildInfoItem(Icons.access_time, session.startTime),
                  _buildInfoItem(Icons.location_on, session.venue),
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => context.push('/session-details/${day.id}', extra: session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('View Full Session Details', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
