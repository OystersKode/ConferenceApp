import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';

class SponsorsScreen extends StatelessWidget {
  const SponsorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> conferencePartners = [
      'assets/PartnerLogo/ConferencePartners/PES.png',
      'assets/PartnerLogo/ConferencePartners/AIP_Logo.png',
      'assets/PartnerLogo/ConferencePartners/Taru Publications.jpg.jpeg',
    ];

    final List<String> associationPartners = [
      'assets/PartnerLogo/AssociationPartners/RJ.png',
      'assets/PartnerLogo/AssociationPartners/Scopus Index.png',
    ];

    final List<String> technicalCoPartners = [
      'assets/PartnerLogo/TechnicalCoPartners/Computer Society of India.png',
      'assets/PartnerLogo/TechnicalCoPartners/Indian Society for Technical Education.png',
      'assets/PartnerLogo/TechnicalCoPartners/The Institution of Electronics and Telecommunication Engineering.png',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionHeader('CONFERENCE PARTNERS'),
                const SizedBox(height: 15),
                ...conferencePartners.map((path) => _buildSponsorImageCard(path)),
                const SizedBox(height: 25),
                _buildSectionHeader('ASSOCIATION PARTNERS'),
                const SizedBox(height: 15),
                ...associationPartners.map((path) => _buildSponsorImageCard(path)),
                const SizedBox(height: 25),
                _buildSectionHeader('TECHNICAL CO-PARTNERS'),
                const SizedBox(height: 15),
                ...technicalCoPartners.map((path) => _buildSponsorImageCard(path)),
                const SizedBox(height: 100), // Space for floating navbar
              ],
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
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
                'Associate Sponsors',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 25),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF708090),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSponsorImageCard(String assetPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
