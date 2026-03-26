import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../models/technical_session_model.dart';
import '../../models/paper_model.dart';

class SessionDetailsScreen extends StatelessWidget {
  final String dayId;
  final TechnicalSessionModel session;

  const SessionDetailsScreen({
    super.key,
    required this.dayId,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: StreamBuilder<List<PaperModel>>(
        stream: firestoreService.getSessionPapers(dayId, session.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final papers = snapshot.data ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.primary,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Session ${session.sessionNumber.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.primary,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildHeaderInfo(Icons.access_time, '${session.startTime} - ${session.endTime}'),
                          const SizedBox(height: 12),
                          _buildHeaderInfo(Icons.location_on_outlined, session.venue),
                          const SizedBox(height: 12),
                          _buildHeaderInfo(Icons.person_outline, 'Chair: ${session.chairs.join(", ")}'),
                          const SizedBox(height: 12),
                          _buildHeaderInfo(Icons.online_prediction, session.mode.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Container(
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
              if (papers.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No papers listed for this session.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPaperCard(papers[index]),
                      childCount: papers.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _buildPaperCard(PaperModel paper) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAPER ${paper.order ?? ""}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paper.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getAuthorsDetails(paper),
            builder: (context, snapshot) {
              final authors = snapshot.data ?? [];
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRESENTERS & AUTHORS',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (authors.isEmpty)
                    Wrap(
                      spacing: 8,
                      children: paper.correspondingAuthors.map((author) => Chip(
                        label: Text(author, style: const TextStyle(fontSize: 11)),
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide.none,
                      )).toList(),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: authors.map((author) {
                        bool isPresenter = author['uid'] == paper.presenterId;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPresenter ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                            border: isPresenter ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isPresenter)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.mic, size: 14, color: AppColors.primary),
                                ),
                              Text(
                                author['name'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isPresenter ? FontWeight.bold : FontWeight.normal,
                                  color: isPresenter ? AppColors.primary : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getAuthorsDetails(PaperModel paper) async {
    List<Map<String, dynamic>> details = [];
    final firestore = FirestoreService();
    
    // Add presenter if available
    if (paper.presenterId != null) {
      final user = await firestore.getUser(paper.presenterId!);
      if (user != null) {
        details.add({
          'name': user.name,
          'uid': user.uid,
          'isPresenter': true,
        });
      }
    }

    // Add co-authors from correspondingAuthors list (filtering out presenter if they are in both)
    for (var authorName in paper.correspondingAuthors) {
      if (details.any((d) => d['name'] == authorName)) continue;
      details.add({
        'name': authorName,
        'uid': null,
        'isPresenter': false,
      });
    }

    return details;
  }
}
