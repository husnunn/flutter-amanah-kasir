/// Konfigurasi lingkungan lewat `--dart-define`. Contoh:
///
///   flutter run                                   // project Firebase asli
///   flutter run --dart-define=USE_EMULATOR=true   // Firebase Emulator di komputer
///   flutter run --dart-define=GALLERY=true        // galeri UI, tanpa Firebase
abstract final class AppEnv {
  /// Hubungkan ke Firebase Emulator (Auth, Firestore, Functions), bukan project asli.
  static const bool useEmulator = bool.fromEnvironment('USE_EMULATOR');

  /// Alamat komputer pengembang dilihat dari perangkat. Emulator Android memakai
  /// `10.0.2.2` (default); HP fisik memakai IP LAN komputer, mis. `192.168.1.10`.
  static const String emulatorHost = String.fromEnvironment(
    'EMULATOR_HOST',
    defaultValue: '10.0.2.2',
  );

  /// Buka galeri layar (data contoh) tanpa menginisialisasi Firebase.
  static const bool showGallery = bool.fromEnvironment('GALLERY');

  /// Region Cloud Functions; harus sama dengan `setGlobalOptions` di functions/index.js.
  static const String functionsRegion = 'asia-southeast2';

  static const String emulatorProjectId = 'demo-amanah-kasir';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
  static const int functionsEmulatorPort = 5001;
}
