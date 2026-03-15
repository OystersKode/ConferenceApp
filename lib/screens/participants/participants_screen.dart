import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';

class ParticipantsScreen extends StatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterSection(),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _getParticipantsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No participants found'));
                }

                final participants = _filterParticipants(snapshot.data!);

                if (participants.isEmpty) {
                  return const Center(child: Text('No results found'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: participants.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    return _buildParticipantCard(participants[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Stream<List<UserModel>> _getParticipantsStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  List<UserModel> _filterParticipants(List<UserModel> users) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;
    return users.where((user) {
      if (user.uid == currentUserId) return false;

      bool matchesFilter = _selectedFilter == 'All' || 
          (_selectedFilter == 'Presenter' && user.role == 'presenter') ||
          (_selectedFilter == 'Delegate' && user.role == 'delegate');
      
      bool matchesSearch = user.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          user.organization.toLowerCase().contains(_searchController.text.toLowerCase());
      
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2E7D32),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('/'),
              ),
              const Expanded(
                child: Text(
                  'Participants',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search participants...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        children: [
          _filterChip('All'),
          const SizedBox(width: 10),
          _filterChip('Presenter'),
          const SizedBox(width: 10),
          _filterChip('Delegate'),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCard(UserModel participant) {
    return InkWell(
      onTap: () => _showParticipantDetails(participant),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: participant.profilePhoto.isNotEmpty 
                  ? NetworkImage(participant.profilePhoto) 
                  : null,
              child: participant.profilePhoto.isEmpty 
                  ? const Icon(Icons.person, size: 40, color: Colors.grey) 
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    participant.organization,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    participant.designation,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.blueGrey.shade200),
          ],
        ),
      ),
    );
  }

  void _showParticipantDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ParticipantDetailSheet(user: user),
    );
  }
}

class _ParticipantDetailSheet extends StatelessWidget {
  final UserModel user;
  const _ParticipantDetailSheet({required this.user});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: user.email,
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: user.phone,
    );
    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FBF9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: user.profilePhoto.isNotEmpty 
                              ? NetworkImage(user.profilePhoto) 
                              : null,
                          child: user.profilePhoto.isEmpty 
                              ? const Icon(Icons.person, size: 70, color: Colors.grey) 
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.organization.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.email,
                        label: 'Email',
                        onTap: _launchEmail,
                      ),
                      const SizedBox(width: 30),
                      _buildActionButton(
                        icon: Icons.chat_bubble,
                        label: 'Chat',
                        onTap: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final currentUserId = authProvider.userModel?.uid;
                          if (currentUserId == null) return;
                          
                          showDialog(
                            context: context, 
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator())
                          );
                          
                          try {
                            final conversationId = await ChatService().getOrCreateConversation(currentUserId, user.uid);
                            if (context.mounted) {
                              Navigator.pop(context); // Pop loading
                              Navigator.pop(context); // Pop sheet
                              context.push('/chat/$conversationId', extra: user.name);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Pop loading
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 30),
                      _buildActionButton(
                        icon: Icons.person_add_alt_1,
                        label: 'Contact',
                        onTap: _launchPhone,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Participant Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(Icons.email_outlined, 'EMAIL ADDRESS', user.email),
                  _buildInfoCard(Icons.public, 'COUNTRY', user.country),
                  _buildInfoCard(Icons.work_outline, 'DESIGNATION', user.designation),
                  _buildInfoCard(Icons.business_outlined, 'COMPANY / INSTITUTE', user.organization),
                  _buildInfoCard(Icons.assignment_ind_outlined, 'REGISTRATION TYPE', 
                      user.role == 'presenter' ? 'Researcher / Presenter' : 'Delegate'),
                  _buildInfoCard(Icons.phone_outlined, 'CONTACT DETAILS', user.phone),
                  
                  if (user.role == 'presenter') ...[
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Associated Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(Icons.description_outlined, 'PAPER TITLE', user.paperTitle ?? 'N/A'),
                    _buildInfoCard(Icons.event_note, 'SESSION INFORMATION', 'To be updated'),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF81C784),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
