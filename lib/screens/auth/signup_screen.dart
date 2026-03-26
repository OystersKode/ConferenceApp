import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _SignUpContent(),
    );
  }
}

class _SignUpContent extends StatefulWidget {
  const _SignUpContent();

  @override
  State<_SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<_SignUpContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _paperTitleController = TextEditingController();

  String _selectedRole = 'delegate'; // Default role
  String? _selectedDelegateType; // For delegate sub-type
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _successMessage;
  bool _isLoading = false;

  final List<String> _delegateTypes = [
    'Industry delegate',
    'Invited delegate',
    'PG/PhD scholar',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _paperTitleController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isLoading || _successMessage != null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.submitSignupRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        delegateType: _selectedRole == 'delegate' ? _selectedDelegateType : null,
        password: _passwordController.text,
        paperTitle: _selectedRole == 'presenter' ? _paperTitleController.text.trim() : null,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage = 'Your request has been sent to admin successfully!';
        });

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.arrow_back, color: Colors.white70),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Expanded(
                              child: Text(
                                'IC-SMART 2026',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildRoleSelection(),
                      const SizedBox(height: 15),
                      if (_selectedRole == 'delegate') ...[
                        _buildDelegateTypeDropdown(),
                        const SizedBox(height: 15),
                      ],
                      _buildInputField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                        validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'example@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        validator: (value) => (value?.length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
                      ),
                      const SizedBox(height: 15),
                      _buildInputField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        icon: Icons.replay_outlined,
                        isPassword: true,
                        isVisible: _isConfirmPasswordVisible,
                        onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        validator: (value) {
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      if (_selectedRole == 'presenter') ...[
                        const SizedBox(height: 15),
                        _buildInputField(
                          controller: _paperTitleController,
                          label: 'Paper Title',
                          hint: 'Enter your paper title',
                          icon: Icons.description_outlined,
                          validator: (value) => _selectedRole == 'presenter' && (value == null || value.isEmpty)
                              ? 'Paper title is required for presenters'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading || _successMessage != null ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: AppColors.primary)
                              : const Text(
                                  'Submit Request',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.white70),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            if (_successMessage != null)
              Positioned(
                bottom: 50,
                left: 50,
                right: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 12),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Register As',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _roleButton('delegate', 'Delegate', Icons.person_outline),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _roleButton('presenter', 'Presenter', Icons.mic_external_on_outlined),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleButton(String value, String label, IconData icon) {
    bool isSelected = _selectedRole == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedRole = value;
        if (value == 'presenter') _selectedDelegateType = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.white70),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDelegateTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type of Delegate',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDelegateType,
          validator: (value) => _selectedRole == 'delegate' && value == null ? 'Please select delegate type' : null,
          items: _delegateTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: (value) => setState(() => _selectedDelegateType = value),
          decoration: InputDecoration(
            hintText: 'Select Type',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey.shade400, size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
