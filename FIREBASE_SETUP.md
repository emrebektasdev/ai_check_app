# TruthLens Firebase Kurulum Rehberi

TruthLens projesi Firebase entegrasyonu kodlanmış olmasına rağmen, çalışabilmesi için Google Cloud/Firebase Console üzerinden uygulamanıza ait yapılandırma dosyalarının oluşturulması ve Firebase ürünlerinin aktifleştirilmesi **zorunludur**.

Lütfen aşağıdaki adımları sırasıyla uygulayın:

---

## Adım 1: Firebase Projesi Oluşturma
1. [Firebase Console](https://console.firebase.google.com/)'a gidin.
2. **"Add Project"** (Proje Ekle) butonuna tıklayın.
3. Proje adı olarak **"TruthLens"** yazın.
4. Google Analytics'i etkinleştirip (isteğe bağlı ama önerilir) projenizi oluşturun.

---

## Adım 2: Google Sign-In (Kimlik Doğrulama) Ayarları
1. Sol menüden **"Build" -> "Authentication"** bölümüne girin.
2. **"Get Started"** diyerek Authentication'ı aktif edin.
3. **"Sign-in method"** sekmesine geçin.
4. **"Google"** sağlayıcısını (provider) seçin.
5. Sağ üstteki butonu aktif hale getirin (Enable).
6. "Project support email" kısmına Google hesabınızı seçin ve **Kaydet**'e tıklayın.

### Ortak Adım: SHA-1 ve SHA-256 İmzası Eklemek (Android İçin Zorunlu!)
Google Sign-in'in Android cihazlarda çalışması için SHA-1 anahtarınıza ihtiyacı vardır.
1. VS Code terminalinde şu komutu çalıştırarak SHA-1 anahtarınızı alın:
   ```bash
   cd c:\Users\emreb\FlutterApps\AI_Check_App\android
   ./gradlew signingReport
   ```
   *(Eğer komut hata verirse, sadece `./gradlew` yerine `gradlew` yazmayı deneyin).*
2. `Task :app:signingReport` çıktısı altındaki `Variant: debug` kısmından **SHA-1** ve **SHA-256** değerlerini kopyalayın.
3. Firebase Console'da sol üstteki **Dişli (Ayarlar)** simgesine -> **"Project settings"** (Proje Ayarları) bölümüne tıklayın.
4. Projenize Android uygulamanızı eklerken veya ekledikten sonra (aşağıdaki FlutterFire adımında uygulamanız otomatik eklenecek) **"SHA certificate fingerprints"** kısmına bu anahtarları yapıştırın.

---

## Adım 3: Cloud Firestore Ayarları (Tarama Geçmişi Metadataları İçin)
1. Sol menüden **"Build" -> "Firestore Database"** bölümüne tıklayın.
2. **"Create database"** butonuna tıklayın.
3. Lokasyon olarak size veya Türkiye'ye en yakın olanı seçin (Örn: `eur3` (Europe)).
4. **Start in test mode** seçeneğiyle (Test modunda başla) ilerleyin.
   *(Test modu 30 gün boyunca okuma/yazma izni verir. İleride kuralları güvenliğe yönelik Firebase arayüzünden güncelleyebilirsiniz).*

---

## Adım 4: Firebase Storage Ayarları (Resimler İçin)
1. Sol menüden **"Build" -> "Storage"** sekmesine tıklayın.
2. **"Get Started"** deyin ve **Test modunda** başlatın.
3. Seçtiğiniz lokasyon Firestore ile aynı kalmalıdır.

---

## Adım 5: FlutterFire CLI Kurulumu ve Projeye Bağlama (En Önemlisi)
Aşağıdaki komutları Android Studio veya VS Code terminalinizde projenin kök dizininde (c:\Users\emreb\FlutterApps\AI_Check_App) sırayla çalıştırın:

1. Eğer bilgisayarınızda Firebase CLI yoksa yükleyin (sadece bir kez yapılır):
   ```bash
   npm install -g firebase-tools
   ```
2. Hesabınıza giriş yapın:
   ```bash
   firebase login
   ```
3. FlutterFire aracını aktif edin:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Projeyi yapılandırın (Proje id kısmına Firebase projenizin URL'sinde yazan ID'yi girin veya listeden seçin):
   ```bash
   flutterfire configure
   ```
   *Not:* Bu komut size Hangi platformlar (Android, iOS) seçmek istediğinizi soracaktır. Ok tuşları ve space ile seçim yapabilirsiniz.
   Bu işlem `lib/firebase_options.dart` adında gerekli tüm API anahtarlarını barındıran kritik bir dosya üretecek ve projenize dahil edecektir.

---

## Kurulum Sonu Test
1. SHA-1 parmak izlerini eklediğinize emin olun.
2. `firebase_options.dart` dosyasının projenizde oluştuğuna emin olun.
3. Uygulamayı sıfırdan derleyip çalıştırın:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

Kurulum sırasında hata alırsanız veya adımlarda yardıma ihtiyacınız olursa bana sorabilirsiniz!
