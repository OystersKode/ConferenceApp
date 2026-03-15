import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/firestore_service.dart';
import '../../models/day_model.dart';
import '../../models/event_model.dart';
import '../../models/technical_session_model.dart';
import '../../models/keynote_model.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String? _selectedDayId;
  final FirestoreService _firestoreService = FirestoreService();
  
  late Stream<List<DayModel>> _daysStream;
  Stream<List<EventModel>>? _eventsStream;
  Stream<List<TechnicalSessionModel>>? _sessionsStream;
  Stream<List<KeynoteModel>>? _keynotesStream;

  @override
  void initState() {
    super.initState();
    _daysStream = _firestoreService.getConferenceDays();
  }

  void _updateDayStreams(String dayId) {
    if (_selectedDayId == dayId) return;
    setState(() {
      _selectedDayId = dayId;
      _eventsStream = _firestoreService.getDayEvents(dayId);
      _sessionsStream = _firestoreService.getDayTechnicalSessions(dayId);
      _keynotesStream = _firestoreService.getDayKeynotes(dayId);
    });
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

          return Column(
            children: [
              _buildHeader(days),
              Expanded(
                child: _buildDayContent(selectedDay),
              ),
            ],
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
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
              Text(
                '27th & 28th March, 2026 • Sangli, India',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
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

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: events.length + (sessions.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < events.length) {
                      return _buildTimelineItem(events[index], day);
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildFeaturedTracksHeader(),
                          const SizedBox(height: 15),
                          _buildFeaturedTracksList(sessions, keynotes, day.id),
                        ],
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineItem(EventModel event, DayModel day) {
    bool ongoing = _isOngoing(event.startTime, event.endTime, day.date);

    switch (event.type) {
      case 'registration':
        return _buildRegistrationCard(event);
      case 'plenary':
      case 'keynote':
        return _buildPlenaryCard(event);
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
              Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A1A1A)),
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
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 5),
                        Text(event.venue.isNotEmpty ? event.venue : 'TBD', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        const Spacer(),
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

  Widget _buildOngoingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'ONGOING',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
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

  bool _isOngoing(String startTime, String endTime, String dayDate) {
    return startTime == '08:45' && dayDate.contains('03-27');
  }
}
