import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/firestore_service.dart';
import '../../models/day_model.dart';
import '../../models/event_model.dart';
import '../../models/technical_session_model.dart';
import '../../models/keynote_model.dart';
import '../../models/paper_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _selectedDayId;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  late Stream<List<DayModel>> _daysStream;
  Stream<List<EventModel>>? _eventsStream;
  Stream<List<TechnicalSessionModel>>? _sessionsStream;
  Stream<List<KeynoteModel>>? _keynotesStream;

  // Cache for papers to allow searching within sessions
  final Map<String, List<PaperModel>> _sessionPapersCache = {};
  bool _isSearchingPapers = false;

  @override
  void initState() {
    super.initState();
    _daysStream = _firestoreService.getConferenceDays();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateDayStreams(String dayId) {
    if (_selectedDayId == dayId) return;
    setState(() {
      _selectedDayId = dayId;
      _eventsStream = _firestoreService.getDayEvents(dayId);
      _sessionsStream = _firestoreService.getDayTechnicalSessions(dayId);
      _keynotesStream = _firestoreService.getDayKeynotes(dayId);
      _sessionPapersCache.clear(); // Clear cache for new day
    });
  }

  Future<void> _prefetchPapers(List<TechnicalSessionModel> sessions, String dayId) async {
    if (_searchQuery.isEmpty || _isSearchingPapers) return;
    
    bool needsFetch = false;
    for (var session in sessions) {
      if (!_sessionPapersCache.containsKey(session.id)) {
        needsFetch = true;
        break;
      }
    }

    if (needsFetch) {
      _isSearchingPapers = true;
      for (var session in sessions) {
        if (!_sessionPapersCache.containsKey(session.id)) {
          final papers = await _firestoreService.getSessionPapers(dayId, session.id).first;
          _sessionPapersCache[session.id] = papers;
        }
      }
      if (mounted) setState(() => _isSearchingPapers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: StreamBuilder<List<DayModel>>(
        stream: _daysStream,
        builder: (context, daySnapshot) {
          if (daySnapshot.hasError) {
            return Center(child: Text('Error: ${daySnapshot.error}'));
          }
          if (daySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!daySnapshot.hasData || daySnapshot.data!.isEmpty) {
            return _buildEmptyState('No days found in schedule.');
          }

          final days = daySnapshot.data!;
          if (_selectedDayId == null) {
            _selectedDayId = days.first.id;
            _eventsStream = _firestoreService.getDayEvents(_selectedDayId!);
            _sessionsStream = _firestoreService.getDayTechnicalSessions(_selectedDayId!);
            _keynotesStream = _firestoreService.getDayKeynotes(_selectedDayId!);
          }

          final selectedDay = days.firstWhere(
            (d) => d.id == _selectedDayId,
            orElse: () => days.first,
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(days),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildDayContent(selectedDay),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/admin-seeder'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Go to Seeder', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<DayModel> days) {
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
                    'Program Schedule',
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
                  Expanded(
                    child: Text(
                      '27th & 28th March, 2026 • Sangli, India',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: days.map((day) => _buildDateTab(day)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTab(DayModel day) {
    bool isSelected = _selectedDayId == day.id;
    DateTime dateTime = DateTime.tryParse(day.date) ?? DateTime.now();
    String month = DateFormat('MMMM').format(dateTime).toUpperCase();
    String dayNum = DateFormat('d').format(dateTime);

    return Expanded(
      child: GestureDetector(
        onTap: () => _updateDayStreams(day.id),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(15),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)] : null,
          ),
          child: Column(
            children: [
              Text(
                month,
                style: TextStyle(
                  color: isSelected ? Colors.grey.shade600 : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dayNum,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by author, paper, speaker, or track...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDayContent(DayModel day) {
    return StreamBuilder<List<EventModel>>(
      stream: _eventsStream,
      builder: (context, eventSnapshot) {
        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        
        final events = eventSnapshot.data ?? [];

        return StreamBuilder<List<TechnicalSessionModel>>(
          stream: _sessionsStream,
          builder: (context, sessionSnapshot) {
            final sessions = sessionSnapshot.data ?? [];

            return StreamBuilder<List<KeynoteModel>>(
              stream: _keynotesStream,
              builder: (context, keynoteSnapshot) {
                final keynotes = keynoteSnapshot.data ?? [];

                if (events.isEmpty && sessions.isEmpty) {
                  return const Center(child: Text('No events scheduled for this day.'));
                }

                // Trigger pre-fetching papers if searching
                if (_searchQuery.isNotEmpty) {
                  _prefetchPapers(sessions, day.id);
                }

                // Filtering logic for events
                final filteredEvents = events.where((e) {
                  if (_searchQuery.isEmpty) return true;
                  bool matches = e.title.toLowerCase().contains(_searchQuery) ||
                         (e.speaker?.toLowerCase().contains(_searchQuery) ?? false) ||
                         (e.organization?.toLowerCase().contains(_searchQuery) ?? false) ||
                         (e.chair?.toLowerCase().contains(_searchQuery) ?? false) ||
                         (e.venue.toLowerCase().contains(_searchQuery));
                  
                  if (matches) return true;

                  if ((e.type == 'panel_discussion' || e.type == 'panel') && e.panelists != null) {
                    return e.panelists!.any((p) => p.toLowerCase().contains(_searchQuery));
                  }
                  return false;
                }).toList();

                // Filtering logic for sessions (searching in session details AND papers)
                final filteredSessions = sessions.where((s) {
                  if (_searchQuery.isEmpty) return true;
                  
                  // Check session details
                  bool matchesSession = s.title.toLowerCase().contains(_searchQuery) ||
                                       s.chairs.any((c) => c.toLowerCase().contains(_searchQuery)) ||
                                       s.venue.toLowerCase().contains(_searchQuery);
                  
                  if (matchesSession) return true;

                  // Check cached papers for this session
                  final papers = _sessionPapersCache[s.id];
                  if (papers != null) {
                    return papers.any((p) => 
                      p.title.toLowerCase().contains(_searchQuery) ||
                      p.correspondingAuthors.any((a) => a.toLowerCase().contains(_searchQuery))
                    );
                  }
                  
                  return false;
                }).toList();

                // Separate events into: Before Technical Session, The Summary itself, and After
                int techIndex = filteredEvents.indexWhere((e) => e.type == 'technical_session');
                
                List<EventModel> beforeEvents = techIndex != -1 ? filteredEvents.sublist(0, techIndex) : filteredEvents;
                EventModel? techSummary = techIndex != -1 ? filteredEvents[techIndex] : null;
                List<EventModel> afterEvents = techIndex != -1 ? filteredEvents.sublist(techIndex + 1) : [];

                return Column(
                  children: [
                    _buildSearchBar(),
                    if (_isSearchingPapers)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text('Searching across sessions...', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    
                    // 1. All events before the technical sessions row
                    ...beforeEvents.map((event) => _buildTimelineItem(event, day)).toList(),
                    
                    // 2. The technical sessions summary row AND Featured Tracks
                    if (techSummary != null) ...[
                      _buildTimelineItem(techSummary, day),
                      if (filteredSessions.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildFeaturedTracksHeader(),
                        const SizedBox(height: 15),
                        _buildFeaturedTracksList(filteredSessions, keynotes, day.id),
                        const SizedBox(height: 30),
                      ],
                    ],

                    // 3. Remaining events (Tea breaks, Parallel sessions, Cultural, etc.)
                    ...afterEvents.map((event) => _buildTimelineItem(event, day)).toList(),

                    if (_searchQuery.isNotEmpty && filteredEvents.isEmpty && filteredSessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text('No results found for your search.', style: TextStyle(color: Colors.grey)),
                      ),
                    const SizedBox(height: 100),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(EventModel event, DayModel day) {
    switch (event.type) {
      case 'registration':
        return _buildRegistrationCard(event);
      case 'plenary':
      case 'keynote':
        return _buildPlenaryCard(event);
      case 'panel_discussion':
      case 'panel':
        return _buildPanelDiscussionCard(event);
      case 'parallel_session':
      case 'online_session':
        return _buildGenericSessionCard(event);
      case 'technical_session':
        return _buildTechnicalSessionSummary(event);
      case 'break':
      case 'lunch':
        return _buildSimpleEventCard(event, Icons.restaurant, Colors.orange.shade700);
      case 'cultural':
        return _buildSimpleEventCard(event, Icons.theater_comedy, Colors.purple.shade700);
      default:
        return _buildSimpleEventCard(event, Icons.event, Colors.blueGrey);
    }
  }

  Widget _buildRegistrationCard(EventModel event) {
    return Container(
      key: ValueKey('reg_${event.id}'),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${event.venue} • ${event.startTime} - ${event.endTime}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPlenaryCard(EventModel event) {
    return Container(
      key: ValueKey('plenary_${event.id}'),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(event.id),
          initiallyExpanded: _searchQuery.isNotEmpty && 
              (event.title.toLowerCase().contains(_searchQuery) || 
               (event.speaker?.toLowerCase().contains(_searchQuery) ?? false)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: Text(
            event.type.toUpperCase().replaceAll('_', ' '),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF004D40), height: 1.2),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(event.speaker ?? 'TBD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(event.organization ?? 'Speaker Affiliation', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 15),
                    if (event.chair != null) ...[
                      _buildIconDetail(Icons.assignment_ind_outlined, 'Chair: ${event.chair}'),
                      const SizedBox(height: 8),
                    ],
                    if (event.moderator != null) ...[
                      _buildIconDetail(Icons.record_voice_over_outlined, 'Moderator: ${event.moderator}'),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Expanded(child: Text(event.venue.isNotEmpty ? event.venue : 'TBD', style: TextStyle(color: Colors.grey.shade700, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 10),
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text('${event.startTime} - ${event.endTime}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                      ],
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

  Widget _buildPanelDiscussionCard(EventModel event) {
    return Container(
      key: ValueKey('panel_${event.id}'),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.indigo.withOpacity(0.3), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(event.id),
          initiallyExpanded: _searchQuery.isNotEmpty && 
              (event.title.toLowerCase().contains(_searchQuery) || 
               (event.panelists?.any((p) => p.toLowerCase().contains(_searchQuery)) ?? false)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          title: const Text(
            'PANEL DISCUSSION',
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E), height: 1.2),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PANEL MEMBERS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (event.panelists ?? []).map((panelist) => Chip(
                        label: Text(panelist, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.indigo.withOpacity(0.2)),
                      )).toList(),
                    ),
                    const SizedBox(height: 15),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 15),
                    if (event.chair != null) ...[
                      _buildIconDetail(Icons.person_outline, 'Chair: ${event.chair}'),
                      const SizedBox(height: 8),
                    ],
                    if (event.moderator != null) ...[
                      _buildIconDetail(Icons.record_voice_over_outlined, 'Moderator: ${event.moderator}'),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(child: _buildIconDetail(Icons.location_on_outlined, event.venue)),
                        const SizedBox(width: 10),
                        _buildIconDetail(Icons.access_time, '${event.startTime} - ${event.endTime}'),
                      ],
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

  Widget _buildGenericSessionCard(EventModel event) {
    Color themeColor = event.type == 'online_session' ? Colors.blue : Colors.teal;
    return Container(
      key: ValueKey('generic_${event.id}'),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: themeColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    event.type.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  '${event.startTime} - ${event.endTime}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
            ),
            if (event.speaker != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.speaker!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                ],
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.black12),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildIconDetail(Icons.location_on_outlined, event.venue)),
                const SizedBox(width: 10),
                if (event.chair != null)
                  Flexible(child: _buildIconDetail(Icons.assignment_ind_outlined, 'Coord: ${event.chair}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Flexible(child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 13))),
      ],
    );
  }

  Widget _buildTechnicalSessionSummary(EventModel event) {
    return Container(
      key: ValueKey('tech_${event.id}'),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(color: Colors.blue.shade200, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              event.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF455A64)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            event.startTime,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleEventCard(EventModel event, IconData iconData, Color iconColor) {
    return Container(
      key: ValueKey('simple_${event.id}'),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('${event.startTime} - ${event.endTime}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTracksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          'Featured Tracks',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
        ),
      ],
    );
  }

  Widget _buildFeaturedTracksList(List<TechnicalSessionModel> sessions, List<KeynoteModel> keynotes, String dayId) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          final keynote = keynotes.firstWhere(
            (k) => k.sessionNumber == session.sessionNumber,
            orElse: () => KeynoteModel(id: '', speaker: 'TBD', title: '', startTime: '', endTime: '', sessionNumber: 0),
          );
          return _buildFeaturedTrackCard(session, keynote, dayId);
        },
      ),
    );
  }

  Widget _buildFeaturedTrackCard(TechnicalSessionModel session, KeynoteModel keynote, String dayId) {
    bool isFirst = session.sessionNumber == 1;
    Color cardColor = isFirst ? const Color(0xFF121E26) : const Color(0xFF004D40);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              session.mode.toUpperCase(),
              style: const TextStyle(color: Color(0xFF4DB6AC), fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Session ${session.sessionNumber.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Track: ${session.title}',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          _buildTrackDetailItem('KEYNOTE SPEAKER', keynote.speaker),
          const SizedBox(height: 10),
          _buildTrackDetailItem('CHAIR', session.chairs.isEmpty ? 'TBD' : session.chairs.join(", ")),
          const Spacer(),
          const Divider(color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                session.startTime,
                style: const TextStyle(color: Color(0xFF4DB6AC), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () => context.push('/session-details/$dayId', extra: session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  minimumSize: const Size(80, 32),
                ),
                child: const Text('Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
