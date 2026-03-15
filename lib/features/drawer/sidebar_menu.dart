import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Drawer(
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(15),
                        image: user?.profilePhoto.isNotEmpty == true
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(user!.profilePhoto),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.profilePhoto.isNotEmpty == true
                          ? null
                          : const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.userId ?? 'ID-0000',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Text('V1.0.1', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('VIEW PROFILE'),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, Icons.person_outline, 'My Digital ID', '/digital-id'),
                _buildMenuItem(context, Icons.info_outline, 'Event Details', '/event-details'),
                _buildMenuItem(context, Icons.calendar_today_outlined, 'Program Schedule', '/schedule'),
                _buildMenuItem(context, Icons.feedback_outlined, 'Submit Feedback', '/feedback'),
                _buildMenuItem(context, Icons.chat_bubble_outline, 'Chat with Peers', '/chat'),
                _buildMenuItem(context, Icons.file_download_outlined, 'PPT Download', '/ppt-download'),
                _buildMenuItem(context, Icons.support_agent, 'Support', '/support'),
                _buildMenuItem(context, Icons.developer_mode, 'App Developer', '/app-developer'),
                const Divider(),
                _buildMenuItem(context, Icons.logout, 'Logout', null, color: Colors.red, isLogout: true),
              ],
            ),
          ),
          
          // Powered By Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/Developer/Oyster.png',
                      height: 45,
                      width: 45,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.apps, color: AppColors.primary, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POWERED BY', style: TextStyle(fontSize: 8, color: Colors.grey)),
                    Text('OYSTER KODE CLUB', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String? route, {Color? color, bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () async {
        Navigator.pop(context); // Close drawer
        
        if (isLogout) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();
          // GoRouter refreshListenable will handle redirect to login
          return;
        }

        if (route != null) {
          context.push(route);
        }
      },
    );
  }
}
