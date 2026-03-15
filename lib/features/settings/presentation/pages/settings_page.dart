import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/providers/settings_notifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final settingsNotifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Premium CTA Card
          if (!settingsState.isPremium) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF007BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'TruthLens Premium',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sınırsız tarama, detaylı model analizleri ve filigransız PDF raporlar için Premium\'a geçin.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showPremiumDialog(context, settingsNotifier);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.accent,
                      elevation: 0,
                    ),
                    child: const Text(
                      'Hemen Yükselt',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Daily Limit Indicator
          _buildSectionTitle(context, 'Kullanımınız'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Günlük Ücretsiz Tarama',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        settingsState.isPremium
                            ? 'Sınırsız'
                            : '${settingsState.dailyScanCount} / 5',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!settingsState.isPremium) ...[
                    LinearProgressIndicator(
                      value: settingsState.dailyScanCount / 5,
                      backgroundColor: AppColors.surface,
                      color: AppColors.accent,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // General Settings
          _buildSectionTitle(context, 'Tercihler'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.accent),
                  title: const Text('Dil'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        settingsState.language == 'tr' ? 'Türkçe' : 'English',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Toggle language logic placeholder
                    final newLang = settingsState.language == 'tr'
                        ? 'en'
                        : 'tr';
                    settingsNotifier.setLanguage(newLang);
                  },
                ),
                const Divider(height: 1, color: AppColors.surface),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode,
                    color: AppColors.accent,
                  ),
                  title: const Text('Koyu Tema'),
                  value: settingsState.isDarkMode,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) {
                    settingsNotifier.toggleDarkMode(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // About
          _buildSectionTitle(context, 'Hakkında'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                  ),
                  title: const Text('Kullanım Koşulları'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.surface),
                ListTile(
                  leading: const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text('Gizlilik Politikası'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Versiyon 1.0.0',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text('Premium Satın Alımı'),
        content: const Text(
          'Bu işlem test amaçlıdır. Premium modunu aktif edeceğim.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.unlockPremium();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tebrikler! Premium aktif edildi.'),
                ),
              );
            },
            child: const Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }
}
