import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  File? _imageFile;
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _designationController;
  late TextEditingController _organizationController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
    _designationController = TextEditingController(text: user?.designation ?? '');
    _organizationController = TextEditingController(text: user?.organization ?? '');
    _aboutController = TextEditingController(text: user?.about ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _designationController.dispose();
    _organizationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel!;

    try {
      String? imageUrl = user.profilePhoto;
      if (_imageFile != null) {
        imageUrl = await CloudinaryService().uploadProfilePhoto(_imageFile!, user.uid) ?? user.profilePhoto;
      }

      final updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'country': _countryController.text.trim(),
        'designation': _designationController.text.trim(),
        'organization': _organizationController.text.trim(),
        'about': _aboutController.text.trim(),
        'profilePhoto': imageUrl,
      };

      await AuthService().completeProfile(user.uid, updatedData);
      await authProvider.refreshUserModel();
      
      setState(() {
        _isEditing = false;
        _imageFile = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).userModel;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(context, user),
              _buildDetailsList(user),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'My Profile',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _isEditing 
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() {
                          _isEditing = false;
                          _imageFile = null;
                          // Reset controllers
                          _nameController.text = user.name;
                          _phoneController.text = user.phone;
                          _countryController.text = user.country;
                          _designationController.text = user.designation;
                          _organizationController.text = user.organization;
                          _aboutController.text = user.about;
                        }),
                      ),
                      IconButton(
                        icon: _isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check, color: Colors.white),
                        onPressed: _isSaving ? null : _saveProfile,
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white24,
                backgroundImage: _imageFile != null 
                    ? FileImage(_imageFile!) 
                    : (user.profilePhoto.isNotEmpty ? NetworkImage(user.profilePhoto) : null) as ImageProvider?,
                child: _imageFile == null && user.profilePhoto.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 40)
                    : _isEditing ? const Icon(Icons.camera_alt, color: Colors.white70, size: 20) : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _isEditing 
            ? IntrinsicWidth(
                child: TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                ),
              )
            : Text(
                user.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'ID: ${user.userId}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERSONAL DETAILS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoItem(Icons.email_outlined, 'EMAIL ADDRESS', user.email, editable: false),
            const Divider(),
            _buildInfoItem(Icons.phone_outlined, 'PHONE NUMBER', user.phone, controller: _phoneController),
            const Divider(),
            _buildInfoItem(Icons.language, 'COUNTRY', user.country, controller: _countryController),
            const Divider(),
            _buildInfoItem(Icons.info_outline, 'ABOUT ME', user.about, controller: _aboutController, maxLines: 3),
          ]),
          const SizedBox(height: 20),
          const Text(
            'PROFESSIONAL INFO',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          _buildInfoCard([
            _buildInfoItem(Icons.work_outline, 'DESIGNATION', user.designation, controller: _designationController),
            const Divider(),
            _buildInfoItem(Icons.business, 'COMPANY / INSTITUTION', user.organization, controller: _organizationController),
            if (user.role == 'presenter') ...[
              const Divider(),
              _buildInfoItem(Icons.description_outlined, 'PAPER TITLE', user.paperTitle ?? 'N/A', editable: false),
              const Divider(),
              _buildAuthorsSection(user),
            ],
          ]),
          const SizedBox(height: 30),
          if (!_isEditing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool editable = true, TextEditingController? controller, int maxLines = 1}) {
    bool editing = _isEditing && editable;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: maxLines > 1 && !editing ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                editing 
                  ? TextFormField(
                      controller: controller,
                      maxLines: maxLines,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        border: UnderlineInputBorder(),
                      ),
                    )
                  : Text(
                      value.isEmpty ? 'Not set' : value,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark),
                      overflow: maxLines == 1 ? TextOverflow.ellipsis : null,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorsSection(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.people_outline, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CORRESPONDING AUTHORS', style: TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 4),
                if (user.correspondingAuthors.isEmpty)
                  const Text('No authors listed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.dark))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: user.correspondingAuthors.map((author) => Chip(
                      label: Text(author, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
