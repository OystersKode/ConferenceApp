import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navbar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userModel?.uid ?? '';
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getUserNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: notifications.length + 1, // Add 1 for the bottom spacing
            itemBuilder: (context, index) {
              if (index == notifications.length) {
                return const SizedBox(height: 100); // Space for floating navbar
              }
              final notification = notifications[index];
              return _buildNotificationItem(context, firestoreService, notification);
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildNotificationItem(BuildContext context, FirestoreService service, NotificationModel notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'account':
        iconData = Icons.person_outline;
        iconColor = Colors.blue;
        break;
      case 'schedule_update':
        iconData = Icons.update;
        iconColor = Colors.orange;
        break;
      case 'message':
        iconData = Icons.chat_bubble_outline;
        iconColor = Colors.green;
        break;
      case 'announcement':
      default:
        iconData = Icons.campaign_outlined;
        iconColor = Colors.red;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (direction) {
        // Implement delete if needed
      },
      child: InkWell(
        onTap: () {
          if (!notification.read) {
            service.markNotificationAsRead(notification.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: notification.read ? Colors.transparent : Colors.green.withOpacity(0.05),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(iconData, color: iconColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.read ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMM d, h:mm a').format(notification.createdAt),
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'We will notify you about important updates!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
