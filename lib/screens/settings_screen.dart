import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/app_colors.dart';
import '../database/db_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _spamCount = 0;
  DateTime? _lastClickTime;
  bool _reminderEnabled = false;

  void _handleEditClick(String label) {
    final now = DateTime.now();
    if (_lastClickTime != null && now.difference(_lastClickTime!).inSeconds > 5) {
      _spamCount = 0;
    }
    _lastClickTime = now;
    _spamCount++;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (_spamCount > 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('jangan spam woi')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label belum tersedia!')),
      );
    }
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text('Yakin mau menghapus SEMUA catatan mood? Tindakan ini nggak bisa dikembalikan!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await DBHelper.deleteAllMoods();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua data telah dihapus!')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus Semua'),
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
        title: const Text('Pengaturan'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profil Pengguna
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logoaot-bg.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (ctx, err, st) => Icon(
                      Icons.shield,
                      size: 100,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pasukan Pengintai',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Prajurit yang berani',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tampilan
            _sectionHeader(context, 'Tampilan', isDark),
            const SizedBox(height: 8),
            _buildActionItem(
              context: context,
              title: 'Mode Gelap',
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                },
                activeTrackColor: AppColors.darkAccentGold,
              ),
              isDark: isDark,
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            const SizedBox(height: 16),

            // Akun
            _sectionHeader(context, 'Akun', isDark),
            const SizedBox(height: 8),
            _buildActionItem(
              context: context,
              title: 'Login (Simpan Cloud)',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkAccentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: AppColors.darkAccentGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              isDark: isDark,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Login Segera Hadir!')),
                );
              },
            ),
            const SizedBox(height: 16),

            // Preferensi
            _sectionHeader(context, 'Preferensi', isDark),
            const SizedBox(height: 8),
            _buildActionItem(
              context: context,
              title: 'Pengingat Harian',
              trailing: Switch(
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                  });
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Pengingat diaktifkan! (fitur notifikasi segera hadir)'
                          : 'Pengingat dinonaktifkan'),
                    ),
                  );
                },
                activeTrackColor: AppColors.darkAccentGold,
              ),
              isDark: isDark,
              onTap: () {
                setState(() {
                  _reminderEnabled = !_reminderEnabled;
                });
              },
            ),
            const SizedBox(height: 16),

            // Kustomisasi
            _sectionHeader(context, 'Kustomisasi', isDark),
            const SizedBox(height: 8),
            _buildActionItem(
              context: context,
              title: 'Edit Mood',
              trailing: const Icon(Icons.chevron_right, size: 20),
              isDark: isDark,
              onTap: () => _handleEditClick('Edit Mood'),
            ),
            const SizedBox(height: 8),
            _buildActionItem(
              context: context,
              title: 'Edit Aktivitas',
              trailing: const Icon(Icons.chevron_right, size: 20),
              isDark: isDark,
              onTap: () => _handleEditClick('Edit Aktivitas'),
            ),
            const SizedBox(height: 16),

            // Data
            _sectionHeader(context, 'Data', isDark),
            const SizedBox(height: 8),
            _buildActionItem(
              context: context,
              title: 'Hapus Semua Data',
              trailing: const Icon(Icons.delete_forever, size: 20, color: Colors.redAccent),
              isDark: isDark,
              onTap: _confirmDeleteAll,
            ),
            const SizedBox(height: 24),

            // Versi
            Center(
              child: Text(
                'Mood Diary Pasukan Pengintai v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required String title,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
