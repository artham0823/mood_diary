import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/mood_entry.dart';
import 'edit_mood_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<MoodEntry>> _moods = {};

  final List<Map<String, dynamic>> moodOptions = [
    {"label": "Sangat Buruk", "color": AppColors.moodVeryBad, "icon": Icons.sentiment_very_dissatisfied},
    {"label": "Buruk", "color": AppColors.moodBad, "icon": Icons.sentiment_dissatisfied},
    {"label": "Biasa", "color": AppColors.moodMeh, "icon": Icons.sentiment_neutral},
    {"label": "Baik", "color": AppColors.moodGood, "icon": Icons.sentiment_satisfied},
    {"label": "Keren", "color": AppColors.moodRad, "icon": Icons.sentiment_very_satisfied},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMoods();
  }

  void _loadMoods() async {
    try {
      final data = await DBHelper.getMoods();
      final Map<DateTime, List<MoodEntry>> grouped = {};
      for (var entry in data) {
        DateTime date = DateTime.parse(entry.date);
        DateTime normalizedDate = DateTime(date.year, date.month, date.day);
        if (grouped[normalizedDate] == null) {
          grouped[normalizedDate] = [];
        }
        grouped[normalizedDate]!.add(entry);
      }
      if (mounted) {
        setState(() {
          _moods = grouped;
        });
      }
    } catch (e) {
      debugPrint("Error loading calendar moods: $e");
    }
  }

  List<MoodEntry> _getEventsForDay(DateTime day) {
    return _moods[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _confirmDelete(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Yakin mau menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (entry.id != null) {
                await DBHelper.deleteMood(entry.id!);
                _loadMoods();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMoods = _selectedDay != null ? _getEventsForDay(_selectedDay!) : <MoodEntry>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: TableCalendar<MoodEntry>(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2101, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.darkAccentGold.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.darkAccentGold,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      final mood = events.last;
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: moodOptions[mood.moodIndex]['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Harian (${_selectedDay != null ? DateFormat('dd MMM yyyy').format(_selectedDay!) : ''})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedMoods.isEmpty)
                    Text(
                      'Belum ada catatan pada hari ini.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    )
                  else
                    ...selectedMoods.map((entry) {
                      final moodData = moodOptions[entry.moodIndex];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: moodData['color'],
                                  radius: 16,
                                  child: Icon(moodData['icon'], size: 16, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  moodData['label'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(Icons.edit, size: 18, color: AppColors.darkAccentGold),
                                  onPressed: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditMoodScreen(entry: entry),
                                      ),
                                    );
                                    if (result == true) _loadMoods();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  onPressed: () => _confirmDelete(entry),
                                ),
                              ],
                            ),
                            if (entry.activities.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Aktivitas: ${entry.activities}', style: const TextStyle(fontSize: 12)),
                            ],
                            if (entry.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(entry.notes, style: const TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
