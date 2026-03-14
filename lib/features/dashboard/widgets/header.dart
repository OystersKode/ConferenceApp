import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: Container(
        width: double.infinity,
        height: 320, // Total height of the header section reverted to 320
        color: AppColors.primary, // Fallback color
        child: Stack(
          children: [
            // 1. THE POSTER IMAGE (Covers the entire green frame)
            Positioned.fill(
              child: Image.asset(
                'assets/images/banner.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                  ),
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 80)),
                  ),
                ),
              ),
            ),
            
            // 2. GRADIENT OVERLAY (Subtle shadow at top for icon visibility)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: statusBarHeight + 80,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // 3. TOP NAVIGATION ICONS (Menu & Search)
            Positioned(
              top: statusBarHeight + 10, // Margin from the top status bar
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
