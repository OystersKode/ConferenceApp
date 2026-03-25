import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/auth_service.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSetupContent();
  }
}

class ProfileSetupContent extends StatefulWidget {
  const ProfileSetupContent({super.key});

  @override
  State<ProfileSetupContent> createState() => _ProfileSetupContentState();
}

class _ProfileSetupContentState extends State<ProfileSetupContent> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();
  final _countryController = TextEditingController();
  final _designationController = TextEditingController();
  final _organizationController = TextEditingController();
  final List<TextEditingController> _authorControllers = [TextEditingController()];
  
  Uint8List? _profileImageBytes;
  bool _isSaving = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void dispose() {
    _phoneController.dispose();
    _aboutController.dispose();
    _countryController.dispose();
    _designationController.dispose();
    _organizationController.dispose();
    for (var controller in _authorControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel!;

    try {
      String? imageUrl = user.profilePhoto;
      if (_profileImageBytes != null) {
        imageUrl = await _cloudinaryService.uploadProfilePhoto(_profileImageBytes!, user.uid) ?? user.profilePhoto;
      }

      final profileData = {
        'phone': _phoneController.text.trim(),
        'about': _aboutController.text.trim(),
        'country': _countryController.text.trim(),
        'designation': _designationController.text.trim(),
        'organization': _organizationController.text.trim(),
        'profilePhoto': imageUrl,
        'profileComplete': true,
      };

      if (user.role == 'presenter') {
        profileData['correspondingAuthors'] = _authorControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }

      await AuthService().completeProfile(user.uid, profileData);
      await authProvider.refreshUserModel();
      
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImageBytes != null 
                          ? MemoryImage(_profileImageBytes!) 
                          : (user.profilePhoto.isNotEmpty ? NetworkImage(user.profilePhoto) : null) as ImageProvider?,
                      child: _profileImageBytes == null && user.profilePhoto.isEmpty
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+1234567890',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _countryController,
                label: 'Country',
                hint: 'e.g. India',
                icon: Icons.public_outlined,
              ),
              _buildTextField(
                controller: _designationController,
                label: 'Designation',
                hint: 'e.g. Professor / Research Scholar',
                icon: Icons.work_outline,
              ),
              _buildTextField(
                controller: _organizationController,
                label: 'Company/Institute',
                hint: 'e.g. RIT, Sangli',
                icon: Icons.business_outlined,
              ),
              _buildTextField(
                controller: _aboutController,
                label: 'About Me',
                hint: 'Brief bio (Max 150 words)',
                icon: Icons.info_outline,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please tell us about yourself';
                  if (_getWordCount(value) > 150) return 'About Me must be max 150 words';
                  return null;
                },
              ),
              if (user.role == 'presenter') ...[
                const SizedBox(height: 32),
                const Text('Paper Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Paper Title', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(user.paperTitle ?? 'N/A', style: const TextStyle(color: Colors.black87)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Corresponding Authors', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                const SizedBox(height: 8),
                ..._authorControllers.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              hintText: 'Author Name',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (_authorControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => setState(() => _authorControllers.removeAt(entry.key)),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _authorControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Corresponding Author'),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Complete Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator ?? (value) => value == null || value.isEmpty ? 'This field is required' : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
          ),
        ],
      ),
    );
  }
}
