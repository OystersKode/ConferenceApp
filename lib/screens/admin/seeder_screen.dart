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

  Future<void> _runSeeder() async {
    setState(() {
      _isSeeding = true;
      _status = 'Reading schedule.json...';
    });

    try {
      // 1. Load the JSON from assets
      final String response = await rootBundle.loadString('assets/ProgramSchedule/schedule.json');
      final data = await json.decode(response);

      setState(() => _status = 'Uploading to Firestore (this may take a minute)...');

      // 2. Call the service method
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
        title: const Text('Database Seeder'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storage, size: 80, color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              if (_isSeeding)
                const CircularProgressIndicator()
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _runSeeder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('SEED DATABASE NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
