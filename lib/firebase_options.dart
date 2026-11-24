// PLACEHOLDER. Berkas ini akan DITIMPA oleh `flutterfire configure`:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=ID-PROJECT-ANDA \
//       --platforms=android --android-package-name=id.amanah.kasir
//
// Langkah lengkap ada di docs/firebase-setup.md. Selama `projectId` masih
// 'belum-dikonfigurasi', aplikasi menampilkan layar "Firebase belum disiapkan"
// (kecuali dijalankan dengan --dart-define=USE_EMULATOR=true atau GALLERY=true).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'belum-dikonfigurasi',
    appId: '1:0:android:0',
    messagingSenderId: '0',
    projectId: 'belum-dikonfigurasi',
  );
}
