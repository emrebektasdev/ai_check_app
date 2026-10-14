import 'dart:convert';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SightEngineService {
  final FirebaseFunctions _functions;
  SightEngineService(this._functions);

  Future<Map<String, dynamic>> checkImage(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous || !user.emailVerified) {
      throw FirebaseFunctionsException(
        code: 'unauthenticated',
        message: 'Analiz için doğrulanmış hesabınızla giriş yapın.',
      );
    }
    if (await imageFile.length() > 5 * 1024 * 1024) {
      throw FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'Görsel en fazla 5 MB olabilir.',
      );
    }
    final bytes = await imageFile.readAsBytes();
    String? mime;
    if (bytes.length >= 3 &&
        bytes[0] == 255 &&
        bytes[1] == 216 &&
        bytes[2] == 255) {
      mime = 'image/jpeg';
    } else if (bytes.length >= 8 &&
        base64Encode(bytes.sublist(0, 8)) == 'iVBORw0KGgo=') {
      mime = 'image/png';
    } else if (bytes.length >= 12 &&
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
      mime = 'image/webp';
    }
    if (mime == null) {
      throw FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'JPEG, PNG veya WebP görsel seçin.',
      );
    }
    final result = await _functions
        .httpsCallable(
          'analyzeImage',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
        )
        .call<Map<String, dynamic>>({
          'imageBase64': base64Encode(bytes),
          'mimeType': mime,
        });
    return result.data;
  }
}
