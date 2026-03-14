import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the status bar height to ensure icons don't overlap with battery/sim status
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        child: Stack(
          children: [
            // --- THE BANNER IMAGE (EDGE-TO-EDGE FROM TOP) ---
            Image.asset(
              'assets/images/banner.jpeg',
              width: double.infinity,
              height: 320, // Adjust height as needed
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 320,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: const Center(
                    child: Text('🌿', style: TextStyle(fontSize: 80)),
                  ),
                );
              },
            ),
            
            // --- TOP SHADOW GRADIENT (FOR ICON VISIBILITY) ---
            Container(
              height: statusBarHeight + 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            
            // --- MENU AND SEARCH ICONS (POSITIONED BELOW STATUS BAR) ---
            Positioned(
              top: statusBarHeight + 8, // Adds margin for battery/sim status
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
