import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/models/scan_history_item.dart';
import 'data/providers/settings_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ScanHistoryItemAdapter());
  await Hive.openBox<ScanHistoryItem>('scan_history');

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Ads
  unawaited(MobileAds.instance.initialize());

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const TruthLensApp(),
    ),
  );
}

class TruthLensApp extends ConsumerWidget {
  const TruthLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    // Watch the goRouterProvider instead of re-creating GoRouter on every build
    final appRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'TruthLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
