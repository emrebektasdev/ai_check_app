import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/providers/scan_notifier.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 100,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    // Connectivity Check
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) ||
        connectivityResult.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İnternet bağlantısı yok! Lütfen kontrol edin.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Authentication and quota are enforced by the server.
    // Start scan
    ref.read(scanNotifierProvider.notifier).scanImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to ScanState changes to navigate or show errors
    ref.listen<ScanState>(scanNotifierProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        // Reset state after showing error
        ref.read(scanNotifierProvider.notifier).reset();
      } else if (next.result != null) {
        // Navigate to results
        context.push(AppRouter.result, extra: next.result);
        // Reset state so going back doesn't trigger again
        ref.read(scanNotifierProvider.notifier).reset();
      }
    });

    final scanState = ref.watch(scanNotifierProvider);
    final hasImage = _selectedImage != null;

    return Scaffold(
      appBar: AppBar(
        leading:
            const BackButton(), // Automatically provided but explicitly shown
        title: const Text('Tarama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Preview Area
            Expanded(
              child: Hero(
                tag: 'scan_button',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textMuted, width: 2),
                      color: hasImage ? AppColors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      image: hasImage
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: hasImage
                        ? (scanState.isLoading
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusLg,
                                  ),
                                  child: Shimmer.fromColors(
                                    baseColor: AppColors.surface.withValues(
                                      alpha: 0.2,
                                    ),
                                    highlightColor: AppColors.accent.withValues(
                                      alpha: 0.5,
                                    ),
                                    child: Container(color: AppColors.surface),
                                  ),
                                )
                              : null)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_search_rounded,
                                size: 64,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Görsel Seçilmedi',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Selection Buttons (disabled when loading)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: scanState.isLoading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(
                      Icons.photo_library,
                      color: AppColors.textPrimary,
                    ),
                    label: const Text(
                      'Galeri',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.textMuted),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: scanState.isLoading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: AppColors.textPrimary,
                    ),
                    label: const Text(
                      'Kamera',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.textMuted),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (hasImage && !scanState.isLoading)
                    ? _analyzeImage
                    : null,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: AppColors.textMuted,
                ),
                child: scanState.isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Görsel analiz ediliyor...'),
                        ],
                      )
                    : const Text('ANALİZ ET'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
