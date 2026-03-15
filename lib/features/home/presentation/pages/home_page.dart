import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/scan_result_model.dart';
import '../../../../data/providers/history_notifier.dart';
import '../../../../data/providers/settings_notifier.dart';
import '../../../../shared/widgets/ad_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(historyNotifierProvider);
    final isPremium = ref.watch(settingsNotifierProvider).isPremium;
    final recentHistory = historyList.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.lens_blur,
                    color: AppColors.accent,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TruthLens',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Welcome Text
              Text(
                'AI Görsel Analizi',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Görsellerin yapay zeka tarafından üretilip üretilmediğini saniyeler içinde öğrenin.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),

              // Scan Button
              Center(
                child: Hero(
                  tag: 'scan_button',
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF007BFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        onTap: () => context.push(AppRouter.scan),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.document_scanner_outlined,
                              size: 48,
                              color: AppColors.background,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Yeni Tarama Başlat',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // History Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son Taramalar',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to history tab via GoRouter branch implicitly if possible,
                      // or just tell the user to use the bottom nav bar.
                      // Since we are in a StatefulShellBranch, the recommended way is bottom nav.
                    },
                    child: const Text(
                      'Tümünü Gör',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // History Cards
              Expanded(
                child: recentHistory.isEmpty
                    ? const Center(
                        child: Text(
                          'Henüz tarama yapılmadı.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        itemCount: recentHistory.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = recentHistory[index];
                          final isAI = item.isAiGenerated;
                          final color = isAI
                              ? AppColors.error
                              : AppColors.success;

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusSm,
                                  ),
                                  image: DecorationImage(
                                    image: FileImage(File(item.imagePath)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Görsel Analizi',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'dd MMM, HH:mm',
                                ).format(item.timestamp),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '%${(item.aiScore * 100).toInt()} AI',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () {
                                // Map history item to ScanResult for the ResultPage
                                final scanResult = ScanResult(
                                  id: item.id,
                                  imageFile: File(item.imagePath),
                                  aiScore: item.aiScore,
                                  confidence: ScanConfidence.values.firstWhere(
                                    (e) => e.name == item.confidence,
                                  ),
                                  detectedModel: item.detectedModel,
                                  timestamp: item.timestamp,
                                );
                                context.push(
                                  AppRouter.result,
                                  extra: scanResult,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              if (!isPremium) const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
