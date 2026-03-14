import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();
  final _countryController = TextEditingController();
  final _designationController = TextEditingController();
  final _organizationController = TextEditingController();
  final List<TextEditingController> _authorControllers = [TextEditingController()];
  
  File? _profileImage;
  bool _isUploading = false;
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isUploading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel!;

    try {
      String? imageUrl = user.profilePhoto;
      if (_profileImage != null) {
        imageUrl = await _cloudinaryService.uploadProfilePhoto(_profileImage!, user.uid) ?? '';
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
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? const Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Upload Profile Photo'),
              const SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(_aboutController, 'About Me (Max 150 words)', Icons.info_outline, maxLines: 3),
              _buildTextField(_countryController, 'Country', Icons.public),
              _buildTextField(_designationController, 'Designation', Icons.work_outline),
              _buildTextField(_organizationController, 'Company/Institute', Icons.business),
              
              if (user.role == 'presenter') ...[
                const Divider(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Paper Title', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(user.paperTitle ?? 'No paper title provided'),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Corresponding Authors', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ..._authorControllers.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Expanded(child: _buildTextField(entry.value, 'Author Name', Icons.person_add_alt)),
                        if (entry.key > 0)
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
                  label: const Text('Add Another Author'),
                ),
              ],
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }
}
