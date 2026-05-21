import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AddMoodScreen extends StatefulWidget {
  const AddMoodScreen({super.key});

  @override
  State<AddMoodScreen> createState() => _AddMoodScreenState();
}

class _AddMoodScreenState extends State<AddMoodScreen> {
  int _selectedMoodIndex = -1;
  final Set<String> _selectedActivities = {};

  final List<Map<String, dynamic>> moods = [
    {"label": "Sangat Buruk", "color": AppColors.moodVeryBad, "icon": Icons.sentiment_very_dissatisfied},
    {"label": "Buruk", "color": AppColors.moodBad, "icon": Icons.sentiment_dissatisfied},
    {"label": "Biasa", "color": AppColors.moodMeh, "icon": Icons.sentiment_neutral},
    {"label": "Baik", "color": AppColors.moodGood, "icon": Icons.sentiment_satisfied},
    {"label": "Keren", "color": AppColors.moodRad, "icon": Icons.sentiment_very_satisfied},
  ];

  final Map<String, List<Map<String, dynamic>>> activityCategories = {
    "Tidur": [
      {"name": "Nyenyak", "icon": Icons.bed},
      {"name": "Kurang", "icon": Icons.hotel},
      {"name": "Buruk", "icon": Icons.bedtime_off},
    ],
    "Misi (Aktivitas)": [
      {"name": "Latihan", "icon": Icons.fitness_center},
      {"name": "Patroli", "icon": Icons.directions_walk},
      {"name": "Istirahat", "icon": Icons.chair},
    ],
    "Kesehatan": [
      {"name": "Bugar", "icon": Icons.favorite},
      {"name": "Luka", "icon": Icons.healing},
      {"name": "Lelah", "icon": Icons.battery_alert},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catat Mood'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bagaimana kabarmu hari ini, prajurit?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(moods.length, (index) {
                final isSelected = _selectedMoodIndex == index;
                final mood = moods[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMoodIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(isSelected ? 4 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.darkAccentGold, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: isSelected ? 28 : 24,
                      backgroundColor: mood["color"],
                      child: Icon(
                        mood["icon"],
                        color: Colors.white,
                        size: isSelected ? 32 : 28,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _selectedMoodIndex != -1 ? moods[_selectedMoodIndex]["label"] : 'Pilih mood',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _selectedMoodIndex != -1 ? moods[_selectedMoodIndex]["color"] : null,
                    ),
              ),
            ),
            const SizedBox(height: 32),
            ...activityCategories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: entry.value.map((activity) {
                        final isSelected = _selectedActivities.contains(activity["name"]);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedActivities.remove(activity["name"]);
                              } else {
                                _selectedActivities.add(activity["name"]);
                              }
                            });
                          },
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.darkAccentGold.withValues(alpha: 0.2)
                                  : (isDark ? const Color(0xFF111111) : AppColors.lightSurface),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.darkAccentGold
                                    : (isDark ? Colors.white10 : Colors.black12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  activity["icon"],
                                  color: isSelected
                                      ? AppColors.darkAccentGold
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  activity["name"],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? AppColors.darkAccentGold
                                            : null,
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _selectedMoodIndex != -1
                ? () {
                    // Save and pop
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Laporan Misi Disimpan!')),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAccentGold,
              foregroundColor: Colors.black87,
              disabledBackgroundColor: isDark ? Colors.white12 : Colors.black12,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
