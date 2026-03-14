import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
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
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 15),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rajanikant Kurane',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'GRA26DE-193',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text('V1.0.02', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('EDIT PROFILE'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(Icons.person_outline, 'My Profile', context),
                _buildMenuItem(Icons.info_outline, 'Event Details', context),
                _buildMenuItem(Icons.calendar_today_outlined, 'Program Schedule', context),
                _buildMenuItem(Icons.note_alt_outlined, 'Saved Notes', context),
                _buildMenuItem(Icons.collections_outlined, 'AI Gallery', context),
                _buildMenuItem(Icons.description_outlined, 'Marketing Collateral', context),
                _buildMenuItem(Icons.developer_mode, 'App Developer', context),
                const Divider(),
                _buildMenuItem(Icons.group_outlined, 'Community', context),
                _buildMenuItem(Icons.logout, 'Logout', context, color: Colors.red),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.apps, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POWERED BY', style: TextStyle(fontSize: 8, color: Colors.grey)),
                    Text('TOMS Foundation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, BuildContext context, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.dark, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppColors.dark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (title == 'My Profile') {
          // Placeholder for navigation to Profile
        }
      },
    );
  }
}
