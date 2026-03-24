import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/bottom_navbar.dart';

class SpeakersScreen extends StatefulWidget {
  const SpeakersScreen({super.key});

  @override
  State<SpeakersScreen> createState() => _SpeakersScreenState();
}

class _SpeakersScreenState extends State<SpeakersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> speakers = [
    {
      'name': 'Dr. Lung-Jieh Yang',
      'role': 'Counselor and Director',
      'org': 'Science and Technology Division, Taipei, TAIWAN',
      'country': 'TAIWAN',
      'image': 'assets/images/Guest/Pahune/Dr. Lung.png',
    },
    {
      'name': 'Prof. Matthew M. Shin',
      'role': 'President',
      'org': 'Pacific States University, USA',
      'country': 'USA',
      'image': 'assets/images/Guest/Pahune/Prof. Shin.png',
    },
    {
      'name': 'Prof. Laurent Chebassier',
      'role': 'Director International Relations',
      'org': 'Alvancity School for Technology, Business and Society, FRANCE',
      'country': 'FRANCE',
      'image': 'assets/images/Guest/Pahune/Prof. Chabassier.png',
    },
    {
      'name': 'Dr. Hsing-Hao Wu',
      'role': 'Vice President',
      'org': 'National University of Kaohsiung, TAIWAN',
      'country': 'TAIWAN',
      'image': 'assets/images/Guest/Pahune/Dr. Wu.png',
    },
    {
      'name': 'Dr. Mohd Amiruddin Rahman',
      'role': 'Deputy Director',
      'org': 'Universiti Putra, MALAYSIA',
      'country': 'MALAYSIA',
      'image': 'assets/images/Guest/Pahune/Dr. Rahman.png',
    },
    {
      'name': 'Prof. Dr. Thomas Himmelsbach',
      'role': 'Former Professor',
      'org': 'Federal Institute for Geosciences and Natural Resources (BGR), GERMANY',
      'country': 'GERMANY',
      'image': 'assets/images/Guest/Pahune/Prof. Himmelbach.png',
    },
    {
      'name': 'Alicia Padrós',
      'role': 'Deputy Director',
      'org': 'Goethe-Institut, GERMANY',
      'country': 'GERMANY',
      'image': 'assets/images/Guest/Pahune/Alicia Pedros.png',
    },
    {
      'name': 'Prof. MAUD LE BARS',
      'role': 'South Asia Area Manager',
      'org': 'Omnes Education, FRANCE',
      'country': 'FRANCE',
      'image': 'assets/images/Guest/Pahune/Prof. Le Bars.png',
    },
    {
      'name': 'Prof. Suraksha Gupta',
      'role': 'Professor',
      'org': 'University of the Arts London, UK',
      'country': 'UK',
      'image': 'assets/images/Guest/Pahune/Prof. Gupta.png',
    },
    {
      'name': 'Dr. Amod Bhat',
      'role': 'School for Technology, Business & Society',
      'org': 'Alvancity, Paris, FRANCE',
      'country': 'FRANCE',
      'image': 'assets/images/Guest/Pahune/Dr. Amod.png',
    },
    {
      'name': 'Dr. Jonas Örtegren',
      'role': 'Professor',
      'org': 'Mid Sweden University, SWEDEN',
      'country': 'SWEDEN',
      'image': 'assets/images/Guest/Pahune/Dr. Jonas.png',
    },
    {
      'name': 'Hon. Makoto SAITO',
      'role': 'Japanese Language Education Advisor',
      'org': 'JAPAN',
      'country': 'JAPAN',
      'image': 'assets/images/Guest/Pahune/Hon. Makoto.png',
    },
    {
      'name': 'Dr. Hai Viet LE',
      'role': 'Faculty of Materials Science and Technology',
      'org': 'Vietnam National University HCM City (VNU-HCM), VIETNAM',
      'country': 'VIETNAM',
      'image': 'assets/images/Guest/Pahune/Dr. Hai.png',
    },
    {
      'name': 'Dr. Viet Van Pham',
      'role': 'HUTECH University',
      'org': 'VIETNAM',
      'country': 'VIETNAM',
      'image': 'assets/images/Guest/Pahune/Dr. Pham.png',
    },
    {
      'name': 'Dr. Manisha Phadatare',
      'role': 'Professor',
      'org': 'Mid Sweden University, SWEDEN',
      'country': 'SWEDEN',
      'image': 'assets/images/Guest/Pahune/Dr. Manisha.png',
    },
    {
      'name': 'Dr. Sandeep P Patil',
      'role': 'Institute of General Mechanics',
      'org': 'RWTH Aachen University, GERMANY',
      'country': 'GERMANY',
      'image': 'assets/images/Guest/Pahune/Dr. Sandeep.png',
    },
    {
      'name': 'Hon. Ram Kunchur',
      'role': 'CEO',
      'org': 'Bionetrik Systems, Bengaluru, INDIA',
      'country': 'INDIA',
      'image': 'assets/images/Guest/Pahune/Hon. Ram.png',
    },
  ];

  List<Map<String, String>> get _filteredSpeakers {
    if (_searchQuery.isEmpty) return speakers;
    return speakers.where((speaker) {
      final name = speaker['name']!.toLowerCase();
      final country = speaker['country']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || country.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredSpeakers;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    if (filteredList.isEmpty) 
                      _buildNoMatchFound()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildSpeakerCard(filteredList[index]);
                        },
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

  Widget _buildNoMatchFound() {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No match found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name or country.',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
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
                    'Speakers',
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
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search speakers...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white60, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = "");
                          },
                        )
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakerCard(Map<String, String> speaker) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.asset(
                speaker['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      speaker['name']!.substring(0, 1),
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker['country']!.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFEC5B13),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  speaker['name']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  speaker['role']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  speaker['org']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black26),
        ],
      ),
    );
  }
}
