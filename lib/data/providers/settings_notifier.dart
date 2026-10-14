import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isDarkMode;
  final String language;
  final int dailyScanCount;
  final bool isPremium;

  const SettingsState({
    required this.isDarkMode,
    required this.language,
    required this.dailyScanCount,
    required this.isPremium,
  });

  // The callable enforces the quota; local preferences are display-only.
  bool get canScan => true;

  SettingsState copyWith({
    bool? isDarkMode,
    String? language,
    int? dailyScanCount,
    bool? isPremium,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  late final SharedPreferences _prefs;

  @override
  SettingsState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return SettingsState(
      isDarkMode: _prefs.getBool('isDarkMode') ?? true,
      language: _prefs.getString('language') ?? 'tr',
      dailyScanCount: _prefs.getInt('dailyScanCount') ?? 0,
      isPremium: false,
    );
  }

  void toggleDarkMode(bool value) {
    _prefs.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
  }

  void setLanguage(String value) {
    _prefs.setString('language', value);
    state = state.copyWith(language: value);
  }

  void incrementScanCount() {
    final newCount = state.dailyScanCount + 1;
    _prefs.setInt('dailyScanCount', newCount);
    state = state.copyWith(dailyScanCount: newCount);
  }

  void resetDailyScanCount() {
    _prefs.setInt('dailyScanCount', 0);
    state = state.copyWith(dailyScanCount: 0);
  }

  // Premium is unavailable until store receipts are verified on the server.
}

// Global Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this provider in main.dart overrides');
});

final settingsNotifierProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(() {
      return SettingsNotifier();
    });
