# Firebase kurulumu
Mevcut proje: `ai-check-app-1ffa4`. Yeni ve açık bir test projesi oluşturmak gerekmez.

1. Google giriş sağlayıcısını etkinleştirin; Android imzalarını Firebase uygulama kaydına ekleyin.
2. Firestore/Storage için kökteki kural dosyalarını kullanın. Geliştirme testlerini demo proje kimliğiyle Emulator Suite üzerinde çalıştırın.
3. Sightengine kimlik bilgileri yalnızca Secret Manager'da tutulur. Mobil uygulama bunları içermez.
4. App Check sağlayıcılarını kaydedin ve `analyzeImage` callable işlevini dağıtın.
5. `flutter pub get`, `flutter analyze` ve `flutter test test/security_test.dart` komutlarını çalıştırın; kayıtlı cihazda giriş ve analiz akışını doğrulayın.

Dağıtım komutları ve gerekli secret adları [SECURITY.md](SECURITY.md) dosyasındadır. Firebase istemci yapılandırması, yetki kurallarının yerine geçmez.
