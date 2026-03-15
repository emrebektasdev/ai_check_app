import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/settings_notifier.dart';

import '../../data/models/scan_result_model.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/result/presentation/pages/result_page.dart';
import '../../features/scan/presentation/pages/scan_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/paywall/presentation/pages/paywall_page.dart';
import '../../shared/widgets/main_layout.dart';

class AppRouter {
  static const String home = '/';
  static const String scan = '/scan';
  static const String result = '/result';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';
  static const String paywall = '/paywall';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final didOnboard = prefs.getBool('onboarding_done') ?? false;

  return GoRouter(
    initialLocation: didOnboard ? AppRouter.home : AppRouter.onboarding,
    routes: [
      // Stateful navigation based on BottomNavigationBar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouter.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouter.history,
                builder: (context, state) => const HistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouter.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      // Standalone routes (Full screen)
      GoRoute(
        path: AppRouter.scan,
        builder: (context, state) => const ScanPage(),
      ),
      GoRoute(
        path: AppRouter.result,
        builder: (context, state) {
          final scanResult = state.extra as ScanResult;
          return ResultPage(result: scanResult);
        },
      ),
      GoRoute(
        path: AppRouter.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRouter.paywall,
        builder: (context, state) => const PaywallPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PaywallPage(),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
        ),
      ),
    ],
  );
});
