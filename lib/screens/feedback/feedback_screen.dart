import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/firestore_service.dart';
import '../../models/feedback_model.dart';
import '../../providers/auth_provider.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _ratingOverall = 4.0;
  double _ratingOrganization = 4.0;
  double _ratingTechnical = 4.0;
  double _ratingVenue = 4.0;
  double _ratingCommunication = 4.0;
  
  final _commentsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    if (user != null && user.feedbackSubmitted) {
      return _buildAlreadySubmittedUI(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Experience',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please share your thoughts on the IC-SMART 2026 Conference sessions.',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 25),
                    
                    _buildSliderCard(
                      title: 'OVERALL EXPERIENCE',
                      question: 'How would you rate your overall experience?',
                      value: _ratingOverall,
                      onChanged: (val) => setState(() => _ratingOverall = val),
                    ),
                    _buildSliderCard(
                      title: 'ORGANIZATION',
                      question: 'How would you rate the event organization?',
                      value: _ratingOrganization,
                      onChanged: (val) => setState(() => _ratingOrganization = val),
                    ),
                    _buildSliderCard(
                      title: 'TECHNICAL SESSIONS',
                      question: 'How satisfied were you with the technical sessions?',
                      value: _ratingTechnical,
                      onChanged: (val) => setState(() => _ratingTechnical = val),
                    ),
                    _buildSliderCard(
                      title: 'VENUE & FACILITIES',
                      question: 'How satisfied were you with the venue facilities?',
                      value: _ratingVenue,
                      onChanged: (val) => setState(() => _ratingVenue = val),
                    ),
                    _buildSliderCard(
                      title: 'COMMUNICATION',
                      question: 'Rate the communication & coordination quality.',
                      value: _ratingCommunication,
                      onChanged: (val) => setState(() => _ratingCommunication = val),
                    ),

                    _buildCommentsInput(
                      title: 'ADDITIONAL COMMENTS',
                      question: 'What was your favorite session and why?',
                      controller: _commentsController,
                      hint: 'Share your thoughts here...',
                    ),
                    
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _submitFeedback(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Submit Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String question,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 25),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) => Text('${index + 1}', style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w600))),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFE0E0E0),
                  inactiveTrackColor: const Color(0xFFE0E0E0),
                  thumbColor: const Color(0xFF2E7D32),
                  overlayColor: const Color(0xFF2E7D32).withOpacity(0.1),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                ),
                child: Slider(
                  value: value,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: onChanged,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('POOR', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    Text('EXCELLENT', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsInput({
    required String title,
    required String question,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 1.1),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade100)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final feedback = FeedbackModel(
        userId: user.userId,
        userName: user.name,
        role: user.role,
        ratingOverall: _ratingOverall.round(),
        ratingOrganization: _ratingOrganization.round(),
        ratingTechnicalSessions: _ratingTechnical.round(),
        ratingVenue: _ratingVenue.round(),
        ratingCommunication: _ratingCommunication.round(),
        comments: _commentsController.text,
        submittedAt: DateTime.now(),
      );

      await FirestoreService().submitConferenceFeedback(feedback, user.uid);
      await authProvider.refreshUserModel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your feedback!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildAlreadySubmittedUI(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 100),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: Color(0xFFF1F8F1), shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 80),
                      ),
                      const SizedBox(height: 30),
                      const Text('Thank You!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                      const SizedBox(height: 10),
                      const Text('Your feedback has already been submitted.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('BACK TO DASHBOARD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 80,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const Text(
                    'Feedback',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                'IC-SMART 2026',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white.withOpacity(0.7), size: 14),
                  const SizedBox(width: 8),
                  Text(
                    '27th & 28th March, 2026 • Sangli, India',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
