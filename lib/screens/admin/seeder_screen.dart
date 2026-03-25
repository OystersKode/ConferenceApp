import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_colors.dart';

class SeederScreen extends StatefulWidget {
  const SeederScreen({super.key});

  @override
  State<SeederScreen> createState() => _SeederScreenState();
}

class _SeederScreenState extends State<SeederScreen> {
  bool _isSeeding = false;
  String _status = 'Ready to seed database...';
  Map<String, dynamic>? _previewData;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final String response = await rootBundle.loadString('assets/ProgramSchedule/schedule.json');
      setState(() {
        _previewData = json.decode(response);
      });
    } catch (e) {
      setState(() => _status = 'Error loading preview: $e');
    }
  }

  Future<void> _runSeeder() async {
    setState(() {
      _isSeeding = true;
      _status = 'Processing schedule data...';
    });

    try {
      final String response = await rootBundle.loadString('assets/ProgramSchedule/schedule.json');
      Map<String, dynamic> data = json.decode(response);

      // --- Data Merging Logic ---
      
      // Day 1 Updates
      final day1 = (data['days'] as List).firstWhere((d) => d['id'] == 'day-1');
      final List day1Events = day1['events'];

      // Ensure Panel Discussion I is present (avoiding simple duplicates by checking title)
      if (!day1Events.any((e) => e['title'].contains('Sustainable Intelligence'))) {
        day1Events.add({
          'title': 'Sustainable Intelligence: Integrating AI for Industry & Academia',
          'type': 'panel',
          'startTime': '11:00',
          'endTime': '12:00',
          'venue': 'Main Auditorium',
          'displayOrder': 3.5,
          'chair': 'Dr. K R Venugopal',
          'panelists': ['Mr. Kalyan Ram', 'Dr. K R Venugopal', 'Dr. Rituparna Datta', 'Dr. Aditya Abhyankar', 'Mr. Vivek Kulkarni'],
        });
      }

      // Day 2 Updates
      final day2 = (data['days'] as List).firstWhere((d) => d['id'] == 'day-2');
      final List day2Events = day2['events'];

      // Ensure Panel Discussion II (The requested info) is correctly seeded
      // We check if it exists, if so we update it, if not we add it.
      const pd2Title = 'Panel Discussion II: Navigating ESG and Sustainability: Powered by AI Innovation';
      final existingPd2Index = day2Events.indexWhere((e) => e['title'] == pd2Title);
      
      final pd2Data = {
        'title': pd2Title,
        'type': 'panel',
        'startTime': '12:20',
        'endTime': '13:00',
        'venue': 'CSE Conference Hall',
        'chair': 'Prof. M. M. Mirza',
        'moderator': 'Dr. Y. J. Kulkarni',
        'panelists': [
          'Mr. Abasaheb Kale',
          'Dr. Kasturi Patil',
          'Mr. Amar Kalvikatte',
          'Mr. Santosh Deshpande',
          'Mr. Sachin Kshirsagar'
        ],
        'displayOrder': 10.0,
      };

      if (existingPd2Index != -1) {
        day2Events[existingPd2Index] = pd2Data;
      } else {
        day2Events.add(pd2Data);
      }

      setState(() => _status = 'Uploading to Firestore...');
      await FirestoreService().seedDatabase(data);

      setState(() {
        _isSeeding = false;
        _status = '✅ Database Seeded Successfully!';
      });
    } catch (e) {
      setState(() {
        _isSeeding = false;
        _status = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Seeder Control'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_previewData != null) _buildPreviewCard(),
            const SizedBox(height: 32),
            _buildStatusArea(),
            const SizedBox(height: 32),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sync Local Schedule', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Text('This will overwrite existing Firestore schedule data with assets/schedule.json + manual patches.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SEEDING PREVIEW (DAY 2)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.groups, color: Colors.blue),
              title: Text('Panel Discussion II', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('12:20 - 13:00 | CSE Conference Hall'),
            ),
            const Text('Panelists:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text('Mr. Abasaheb Kale, Dr. Kasturi Patil, Mr. Amar Kalvikatte, Mr. Santosh Deshpande, Mr. Sachin Kshirsagar', 
                 style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            const Text('Chair: Prof. M. M. Mirza', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          if (_isSeeding) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ]
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSeeding ? null : _runSeeder,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        child: Text(_isSeeding ? 'SEEDING IN PROGRESS...' : 'SEED DATABASE NOW', 
             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
