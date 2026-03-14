import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OrganizerSection extends StatelessWidget {
  const OrganizerSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'ORGANISERS',
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
                  'VIEW ALL',
                  style: TextStyle(color: AppColors.secondary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(10),
                  height: 60,
                  width: 80,
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
                  child: const Center(
                    child: Text('🏢', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
