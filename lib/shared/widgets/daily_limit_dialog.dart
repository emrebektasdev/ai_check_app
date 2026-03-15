import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/settings_notifier.dart';

class DailyLimitDialog extends ConsumerWidget {
  const DailyLimitDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current language from settings (Assuming setting state has lang, if not just default to TR logic)
    final lang = ref.watch(settingsNotifierProvider).language;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.warning, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppStrings.limitReachedTitleTR.tr(lang),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Text(
        AppStrings.limitReachedDescTR.tr(lang),
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            AppStrings.closeTR.tr(lang),
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
          ),
          onPressed: () {
            context.pop(); // Close dialog
            // Navigate to Paywall conceptually...
            // e.g. context.push('/paywall'); but for now we might trigger it directly or go to settings
            // Let's assume there is a /paywall route
            context.push('/paywall');
          },
          child: Text(
            AppStrings.getProButtonTR.tr(lang),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
