import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> speakers = [
    {
      'name': 'Dr. Arpan Kumar',
      'role': 'PhD Student',
      'org': 'NICOLAUS COPERNICUS UNIVERSITY',
      'emoji': '👨‍⚕️',
    },
    {
      'name': 'Sarah Jenkins',
      'role': 'Lead Scientist',
      'org': 'INDIAN INSTITUTE OF TECHNOLOGY',
      'emoji': '👩‍🔬',
    },
    {
      'name': 'Prof. James Wilson',
      'role': 'Graphene Research Head',
      'org': 'UNIVERSITY OF MANCHESTER',
      'emoji': '👨‍🏫',
    },
    {
      'name': 'Dr. Elena Rodriguez',
      'role': 'Materials Associate',
      'org': 'STANFORD UNIVERSITY',
      'emoji': '👩‍💼',
    },
    {
      'name': 'Rohan Gupta',
      'role': 'Research Scholar',
      'org': 'IISc BANGALORE',
      'emoji': '👨‍🎓',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: speakers.length,
              itemBuilder: (context, index) {
                return _buildSpeakerCard(speakers[index]);
              },
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
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
              const Expanded(
                child: Text(
                  'Speakers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance for back button
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search speakers...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerCard(Map<String, String> speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          // Speaker Avatar (using emoji as placeholder)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
            ),
            child: Center(
              child: Text(
                speaker['emoji']!,
                style: const TextStyle(fontSize: 35),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Speaker Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker['org']!,
                  style: const TextStyle(
                    color: Color(0xFFEC5B13),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  speaker['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  speaker['role']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}
