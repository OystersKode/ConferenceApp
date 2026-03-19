import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_navbar.dart';

class DigitalIdScreen extends StatelessWidget {
  const DigitalIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access user model from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.userModel;

    // Use the generated User ID for QR content
    final String qrData = userModel?.userId ?? 'GUEST-USER';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital ID'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 12,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Conference Branding
                      const Text(
                        'IC-SMART 2026',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'INTERNATIONAL CONFERENCE',
                        style: TextStyle(
                          fontSize: 12, 
                          letterSpacing: 2.0, 
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          foregroundColor: AppColors.dark,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // User Info
                      Text(
                        userModel?.name ?? 'Loading...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userModel?.userId ?? 'ID Pending',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        userModel?.role.toUpperCase() ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 40),
                      
                      // Validity Badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'ENTRY PASS: MAR 27-28, 2026',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Please present this QR code at the registration desk for verification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 100), // Space for floating navbar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
