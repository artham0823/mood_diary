import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../database/db_helper.dart';
import '../models/mood_entry.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _totalEntries = 0;
  int _streak = 0;
  String _averageMood = '0.0';
  bool _isLoading = true;
  List<MoodEntry> _allEntries = [];

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
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final entries = await DBHelper.getMoods();
      if (entries.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _totalEntries = 0;
            _streak = 0;
            _averageMood = '0.0';
            _allEntries = [];
          });
        }
        return;
      }

      _allEntries = entries;
      _totalEntries = entries.length;

      double sum = 0;
      for (var e in entries) {
        sum += (e.moodIndex + 1);
      }
      _averageMood = (sum / _totalEntries).toStringAsFixed(1);

      List<DateTime> dates = entries.map((e) {
        DateTime dt = DateTime.parse(e.date);
        return DateTime(dt.year, dt.month, dt.day);
      }).toSet().toList();
      dates.sort((a, b) => b.compareTo(a));

      int currentStreak = 0;
      DateTime today = DateTime.now();
      DateTime checkDate = DateTime(today.year, today.month, today.day);

      if (dates.isNotEmpty &&
          (dates.first.isAtSameMomentAs(checkDate) ||
              dates.first.isAtSameMomentAs(checkDate.subtract(const Duration(days: 1))))) {
        DateTime expectedDate = dates.first;
        for (var d in dates) {
          if (d.isAtSameMomentAs(expectedDate)) {
            currentStreak++;
            expectedDate = expectedDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }
      _streak = currentStreak;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _totalEntries = 0;
          _allEntries = [];
        });
      }
    }
  }

  // Hitung jumlah entry per mood
  Map<int, int> _getMoodDistribution() {
    Map<int, int> dist = {};
    for (var e in _allEntries) {
      dist[e.moodIndex] = (dist[e.moodIndex] ?? 0) + 1;
    }
    return dist;
  }

  // Hitung mood per hari untuk 7 hari terakhir
  List<MapEntry<String, double>> _getLast7DaysMood() {
    List<MapEntry<String, double>> result = [];
    DateTime now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      String dayStr = '${day.day}/${day.month}';
      String dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      var entries = _allEntries.where((e) => e.date == dateStr).toList();
      if (entries.isNotEmpty) {
        double avg = entries.map((e) => e.moodIndex + 1).reduce((a, b) => a + b) / entries.length;
        result.add(MapEntry(dayStr, avg));
      } else {
        result.add(MapEntry(dayStr, 0));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistik'),
            Text(
              'Kemajuan perjalananmu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _totalEntries == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 80, color: isDark ? Colors.white24 : Colors.black26),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada nih datanya,\nayok catat moodmu!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Stat Cards
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(context, '$_streak', 'Hari\nBeruntun', isDark)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatCard(context, '$_totalEntries', 'Total\nEntri', isDark)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildStatCard(context, _averageMood, 'Rata-rata\nMood', isDark)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grafik 7 Hari Terakhir
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mood 7 Hari Terakhir',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 140,
                              child: _buildMoodChart(context, isDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Distribusi Mood
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Distribusi Mood',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildMoodDistribution(context, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMoodChart(BuildContext context, bool isDark) {
    final data = _getLast7DaysMood();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((entry) {
        double barHeight = entry.value > 0 ? (entry.value / 5.0) * 100 : 4;
        Color barColor;
        if (entry.value == 0) {
          barColor = isDark ? Colors.white10 : Colors.black12;
        } else if (entry.value <= 1) {
          barColor = AppColors.moodVeryBad;
        } else if (entry.value <= 2) {
          barColor = AppColors.moodBad;
        } else if (entry.value <= 3) {
          barColor = AppColors.moodMeh;
        } else if (entry.value <= 4) {
          barColor = AppColors.moodGood;
        } else {
          barColor = AppColors.moodRad;
        }

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (entry.value > 0)
                Text(
                  entry.value.toStringAsFixed(1),
                  style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : Colors.black54),
                ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.key,
                style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : Colors.black54),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodDistribution(BuildContext context, bool isDark) {
    final dist = _getMoodDistribution();
    return Column(
      children: List.generate(5, (index) {
        int count = dist[index] ?? 0;
        final mood = moodOptions[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: mood['color'],
                radius: 14,
                child: Icon(mood['icon'], size: 14, color: Colors.white),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: Text(
                  mood['label'],
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _totalEntries > 0 ? count / _totalEntries : 0,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(mood['color']),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
