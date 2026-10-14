import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_check_app/data/providers/settings_notifier.dart';
import 'package:ai_check_app/data/repositories/scan_repository.dart';
import 'package:ai_check_app/data/services/sight_engine_service.dart';

class FakeService implements SightEngineService {
  final Map<String, dynamic> response;
  FakeService(this.response);
  @override
  Future<Map<String, dynamic>> checkImage(File file) async => response;
}

void main() {
  test('legacy local premium flag cannot grant paid entitlement', () async {
    SharedPreferences.setMockInitialValues({'isPremium': true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(settingsNotifierProvider).isPremium, isFalse);
  });
  test(
    'missing or invalid scores cannot become a false authentic result',
    () async {
      for (final value in [null, -1, 2, double.nan]) {
        final result = await ScanRepository(
          FakeService({
            'type': {'ai_generated': value},
          }),
        ).analyzeImage(File('test.jpg'));
        expect(result.isLeft(), isTrue);
      }
    },
  );
  test('probability does not fabricate an image generator identity', () async {
    final result = await ScanRepository(
      FakeService({
        'type': {'ai_generated': 0.99},
      }),
    ).analyzeImage(File('test.jpg'));
    expect(result.isRight(), isTrue);
    result.fold(
      (error) => fail(error),
      (scan) => expect(scan.detectedModel, isNull),
    );
  });
}
