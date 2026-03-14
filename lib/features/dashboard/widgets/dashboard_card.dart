import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class FeatureCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displaying icon directly without the background block
            Image.asset(
              iconPath,
              width: 80, // Increased size for better visibility
              height: 80,
              errorBuilder: (context, error, stackTrace) => 
                  Icon(Icons.help_outline, color: AppColors.primary, size: 45),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
