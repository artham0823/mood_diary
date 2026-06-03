import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/mood_entry.dart';

class EditMoodScreen extends StatefulWidget {
  final MoodEntry entry;
  const EditMoodScreen({super.key, required this.entry});

  @override
  State<EditMoodScreen> createState() => _EditMoodScreenState();
}

class _EditMoodScreenState extends State<EditMoodScreen> {
  late int _selectedMoodIndex;
  late Set<String> _selectedActivities;
  late DateTime _selectedDate;
  late TextEditingController _notesController;

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
  void initState() {
    super.initState();
    _selectedMoodIndex = widget.entry.moodIndex;
    _selectedActivities = widget.entry.activities.isNotEmpty
        ? widget.entry.activities.split(',').toSet()
        : {};
    _selectedDate = DateTime.parse(widget.entry.date);
    _notesController = TextEditingController(text: widget.entry.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateEntry() async {
    if (_selectedMoodIndex == -1) return;

    final updatedEntry = widget.entry.copyWith(
      moodIndex: _selectedMoodIndex,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      activities: _selectedActivities.join(','),
      notes: _notesController.text,
    );

    try {
      await DBHelper.updateMood(updatedEntry);
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui!')),
        );
      }
    } catch (e) {
      debugPrint('Error updating mood: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mood'),
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
              'Ubah catatan moodmu, prajurit!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppColors.darkAccentGold),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
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
                                        color: isSelected ? AppColors.darkAccentGold : null,
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
            const SizedBox(height: 16),
            Text(
              'Catatan Harian (Opsional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tulis laporan misi hari ini...',
                filled: true,
                fillColor: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.darkAccentGold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _updateEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAccentGold,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Perbarui',
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
