import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/providers/settings_notifier.dart';

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsNotifierProvider).language;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF0F2027), Color(0xFF203A43)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 24),
                // Icon / Logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    size: 64,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.paywallTitle,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sınırları Kaldırın',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 48),

                // Features
                _buildFeatureRow(AppStrings.paywallFeature1TR.tr(lang)),
                const SizedBox(height: 16),
                _buildFeatureRow(AppStrings.paywallFeature2TR.tr(lang)),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  AppStrings.paywallFeature3TR.tr(lang),
                  isSoon: true,
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(
                  AppStrings.paywallFeature4TR.tr(lang),
                  isSoon: true,
                ),
                const Spacer(),

                // Price Mock
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceCard(
                        context,
                        'Aylık',
                        AppStrings.buyMonthlyTR.tr(lang),
                        false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceCard(
                        context,
                        'Yıllık',
                        AppStrings.buyYearlyTR.tr(lang),
                        true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .unlockPremium();
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pro versiyona geçildi (Test)'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'TruthLens Pro\'yu Başlat',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    AppStrings.maybeLaterTR.tr(lang),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text, {bool isSoon = false}) {
    return Row(
      children: [
        Icon(
          isSoon ? Icons.schedule : Icons.check_circle,
          color: isSoon ? AppColors.textMuted : AppColors.success,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isSoon ? AppColors.textMuted : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(
    BuildContext context,
    String title,
    String price,
    bool isPopular,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: isPopular
            ? AppColors.accent.withValues(alpha: 0.1)
            : AppColors.surface,
        border: Border.all(
          color: isPopular ? AppColors.accent : AppColors.surface,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'EN POPÜLER',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
