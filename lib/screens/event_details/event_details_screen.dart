import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundLight = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 10,
                          bottom: 80,
                          left: 20,
                          right: 20,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => context.go('/'),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                  ),
                                ),
                                const Text(
                                  'Event Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'IC-SMART 2026',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  '27th & 28th March, 2026 • Pune, India',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Main Content
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // About / Organizing Institute Card
                          _buildAboutCard(),

                          const SizedBox(height: 20),

                          // Conference Highlights Card
                          _buildHighlightsCard(),

                          const SizedBox(height: 20),

                          // Theme Tracks Card
                          _buildThemeTracksCard(),

                          const SizedBox(height: 20),

                          // Important Dates Card
                          _buildImportantDatesCard(),

                          const SizedBox(height: 20),

                          // Organizers Card
                          _buildOrganizersCard(),

                          const SizedBox(height: 20),

                          // Contact / Submission Card
                          _buildContactCard(),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.info, 'About Organizing Institute'),
          const SizedBox(height: 16),
          const Text(
            'Rajarambapu Institute of Technology',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'An empowered autonomous institute, Affiliated to Shivaji University',
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const Divider(height: 32),
          const Text(
            'International Conference on Sustainable Management and Advanced Research Technologies (IC-SMART 2026)',
            style: TextStyle(fontSize: 15, color: Color(0xFF334155), fontWeight: FontWeight.w600, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Website: https://www.ritindia.edu',
            style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge('NAAC A+ Grade'),
              const SizedBox(width: 8),
              _buildBadge('NBA Accredited'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHighlightsCard() {
    final highlights = [
      'Sustainable Management Practices & Circular Economy',
      'Climate-Resilient Technologies',
      'Smart Cities & Infrastructure',
      'Renewable Energy Systems',
      'Sustainable Finance & Digital Transformation',
      'AI-driven sustainability analytics',
      'Blockchain for transparent supply chains',
      'Environmental monitoring using big data',
      'Advanced materials for green engineering',
      'Global Networking opportunities',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.stars, 'Conference Highlights'),
          const SizedBox(height: 16),
          ...highlights.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    h,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.4),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildThemeTracksCard() {
    final tracks = [
      'Sustainable Energy Management and AI-Driven Renewable Technologies',
      'Green Computing and IoT for Resource-Efficient Management',
      'Advanced Materials Management and Nanotechnology for Eco-Innovation',
      'Biomedical Intelligence and Sustainable Healthcare Management',
      'Intelligent Urban Management and Environmental Resilience Technologies',
      'Responsible AI and Ethical Management in Advanced Technologies',
      'Data Analytics and Quantum Technologies for Sustainable Optimization',
      'Interdisciplinary Deep Learning Applications in Sustainable Management',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.account_tree, 'Theme Tracks'),
          const SizedBox(height: 16),
          ...tracks.map((track) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFF10B981), width: 4)),
            ),
            child: Text(
              track,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildImportantDatesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.event_available, 'Important Dates'),
          const SizedBox(height: 16),
          _buildDateRow('Paper Submission', '11 Jan 2026'),
          _buildDateRow('Reviewer Decision', '26 Jan 2026'),
          _buildDateRow('Registration Deadline', '05 Feb 2026'),
          _buildDateRow('Late Registration', '25 Feb 2026'),
          _buildDateRow('Conference Dates', '27-28 Mar 2026', isLast: true),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, String date, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildOrganizersCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.groups, 'Key Organizers'),
          const SizedBox(height: 16),
          _buildOrganizerItem('Chief Patron', 'Hon. Mr. BhagatSingh Patil', 'Chairman, BOG, RIT'),
          _buildOrganizerItem('Patron', 'Hon. Prin. R. D. Sawant', 'Secretary, K. E. Society'),
          _buildOrganizerItem('Convener', 'Dr. Vijay H. Kalmani', 'Professor, CSE'),
          _buildOrganizerItem('Organizing Secretary', 'Dr. Ramchandra G. Desavale', 'Professor, Mechatronics', isLast: true),
        ],
      ),
    );
  }

  Widget _buildOrganizerItem(String role, String name, String sub, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981), letterSpacing: 1)),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Text(sub, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(Icons.contact_support, 'Submission & Contact'),
          const SizedBox(height: 16),
          _buildContactItem(Icons.language, 'Website', 'https://ic-smart.com/'),
          _buildContactItem(Icons.upload_file, 'Submission', 'https://tinyurl.com/ritsmart'),
          _buildContactItem(Icons.email, 'Email', 'rit@ic-smart.com'),
          _buildContactItem(Icons.phone, 'Contact', '+91 9024103815', isLast: true),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }
}
