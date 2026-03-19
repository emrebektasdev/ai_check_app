import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/scan_result_model.dart';

class ResultPage extends ConsumerStatefulWidget {
  final ScanResult result;

  const ResultPage({super.key, required this.result});

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareResult() async {
    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = await File(
          '${directory.path}/result_screenshot.png',
        ).create();
        await imagePath.writeAsBytes(image);

        // Usage of Share.shareXFiles for modern share_plus
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(imagePath.path)],
            text: 'TruthLens Analiz Sonucum!',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşım sırasında bir hata oluştu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiProbability = widget.result.aiScore;
    final isAI = widget.result.isAiGenerated;
    final resultTitle = isAI ? 'AI Generated' : 'Real Image';
    final resultColor = isAI ? AppColors.error : AppColors.success;
    final modelName = widget.result.detectedModel ?? 'Bilinmiyor';
    final confidenceBadge = widget.result.confidence.name.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiz Sonucu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareResult,
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Theme.of(
            context,
          ).scaffoldBackgroundColor, // Ensure screenshot has background
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Circular Percentage Indicator
                Center(
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: aiProbability),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 16,
                              backgroundColor: AppColors.surface,
                              color: resultColor,
                              strokeCap: StrokeCap.round,
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${(value * 100).toInt()}%',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: resultColor,
                                          fontSize: 48,
                                        ),
                                  ),
                                  Text(
                                    'AI',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title and Badge
                Text(
                  resultTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 16),

                // Info Row (Confidence & Model)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(
                      'GÜVEN: $confidenceBadge',
                      isAI ? AppColors.error : AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _buildBadge('MODEL: $modelName', AppColors.accent),
                  ],
                ),
                const SizedBox(height: 40),

                // Share CTA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _shareResult,
                    icon: const Icon(Icons.share),
                    label: const Text('Raporu Paylaş'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
