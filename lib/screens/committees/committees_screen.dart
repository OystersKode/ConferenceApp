import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';

class CommitteesScreen extends StatelessWidget {
  const CommitteesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> members = [
      {
        'name': 'Aravind Vijayaraghavan',
        'org': 'The University of Manchester (UK)',
        'emoji': '👤',
      },
      {
        'name': 'Seema Ansari',
        'org': 'C-MET/MeitY (India)',
        'emoji': '👤',
      },
      {
        'name': 'Ratheesh Ravendran',
        'org': 'C-MET, Thrissur (India)',
        'emoji': '👤',
      },
      {
        'name': 'Antonio Correia',
        'org': 'Phantoms Foundation (Spain)',
        'emoji': '👤',
      },
      {
        'name': 'Elena Rossi',
        'org': 'University of Cambridge (UK)',
        'emoji': '👤',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'COMMITTEE MEMBERS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF708090),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return _buildMemberCard(members[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 10),
          const Text(
            'Organizing Committee',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, String> member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE2E2E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                member['emoji']!,
                style: const TextStyle(fontSize: 50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          member['name']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          member['org']!,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
