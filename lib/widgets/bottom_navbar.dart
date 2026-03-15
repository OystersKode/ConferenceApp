import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../services/firestore_service.dart';
import '../models/notification_model.dart';
import '../providers/auth_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userModel?.uid ?? '';
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            Icons.home, 
            'HOME', 
            currentRoute == '/', 
            onTap: () => context.go('/')
          ),
          
          // ALERTS Tab with Notification Badge
          StreamBuilder<List<NotificationModel>>(
            stream: FirestoreService().getUserNotifications(userId),
            builder: (context, snapshot) {
              final unreadCount = snapshot.hasData 
                  ? snapshot.data!.where((n) => !n.read).length 
                  : 0;
              
              return _buildNavItem(
                unreadCount > 0 ? Icons.notifications_active : Icons.notifications_none,
                'ALERTS',
                currentRoute == '/notifications',
                badgeCount: unreadCount,
                onTap: () => context.push('/notifications'),
              );
            }
          ),

          _buildNavItem(
            Icons.qr_code_scanner, 
            'SCANNER', 
            currentRoute == '/digital-id', 
            onTap: () => context.push('/digital-id')
          ),
          
          _buildNavItem(
            Icons.person_outline, 
            'PROFILE', 
            currentRoute == '/profile', 
            onTap: () => context.push('/profile')
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap, int badgeCount = 0}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.white : Colors.white60,
                  size: 26,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
