import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OrganizerSection extends StatelessWidget {
  const OrganizerSection({super.key});

  @override
  Widget build(BuildContext context) {
    // List of partner logos from assets/PartnerLogo/ConferencePartners
    final List<String> partnerLogos = [
      'assets/PartnerLogo/ConferencePartners/PES.png',
      'assets/PartnerLogo/ConferencePartners/AIP_Logo.png',
      'assets/PartnerLogo/ConferencePartners/Taru Publications.jpg.jpeg',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'CONFERENCE PARTNERS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '',
                  style: TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: partnerLogos.map((logoPath) {
                return Container(
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(8),
                  height: 70,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      logoPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.corporate_fare, color: Colors.grey),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
