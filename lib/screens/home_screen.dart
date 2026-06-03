import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import 'add_mood_screen.dart';
import 'edit_mood_screen.dart';
import '../database/db_helper.dart';
import '../models/mood_entry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MoodEntry> _entries = [];
  bool _isLoading = true;

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
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await DBHelper.getMoods();
      if (mounted) {
        setState(() {
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading moods: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDelete(MoodEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: const Text('Yakin mau menghapus catatan ini? Nggak bisa dikembalikan lho!'),
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
                _loadEntries();
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jurnal Mood',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Catatan perjalananmu sebagai prajurit',
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
        : _entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logoaot-bg.png',
                    width: 160,
                    height: 160,
                    errorBuilder: (ctx, err, st) => Icon(
                      Icons.menu_book,
                      size: 120,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Belum Ada Catatan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai perjalananmu dengan\nmencatat mood hari ini',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const AddMoodScreen()),
                      );
                      if (result == true) _loadEntries();
                    },
                    icon: const Icon(Icons.add, color: Colors.black87),
                    label: Text(
                      'Catat Mood',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkAccentGold,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final moodData = moodOptions[entry.moodIndex];
                DateTime date = DateTime.parse(entry.date);

                return GestureDetector(
                  onTap: () async {
                    // Tap card => Edit
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditMoodScreen(entry: entry),
                      ),
                    );
                    if (result == true) _loadEntries();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: moodData['color'],
                              radius: 18,
                              child: Icon(moodData['icon'], size: 20, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    moodData['label'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(date),
                                    style: TextStyle(
                                      color: isDark ? Colors.white54 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, size: 20, color: AppColors.darkAccentGold),
                              onPressed: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditMoodScreen(entry: entry),
                                  ),
                                );
                                if (result == true) _loadEntries();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(entry),
                            ),
                          ],
                        ),
                        if (entry.activities.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: entry.activities.split(',').map((a) {
                              return Chip(
                                label: Text(a.trim(), style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ],
                        if (entry.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            entry.notes,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMoodScreen()),
          );
          if (result == true) _loadEntries();
        },
        backgroundColor: AppColors.darkAccentGold,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}
