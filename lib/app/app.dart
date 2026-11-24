import 'package:material_ui/material_ui.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../core/theme/theme.dart';
import '../dev/screen_gallery.dart';
import '../features/auth/presentation/auth_gate.dart';
import '../features/auth/presentation/setup_needed_screen.dart';

/// Akar aplikasi: tema terang, bahasa Indonesia, dan halaman awal sesuai
/// status Firebase:
/// - [FirebaseStatus.ready]: `AuthGate` (login sungguhan, butuh `ProviderScope`)
/// - [FirebaseStatus.notConfigured]: panduan menyambungkan Firebase
/// - [FirebaseStatus.skipped]: galeri layar dengan data contoh
class AmanahKasirApp extends StatelessWidget {
  const AmanahKasirApp({
    super.key,
    this.firebaseStatus = FirebaseStatus.skipped,
  });

  final FirebaseStatus firebaseStatus;

  static const Locale _locale = Locale('id', 'ID');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amanah Kasir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      locale: _locale,
      supportedLocales: const [_locale],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: switch (firebaseStatus) {
        FirebaseStatus.ready => const AuthGate(),
        FirebaseStatus.notConfigured => const SetupNeededScreen(),
        FirebaseStatus.skipped => const ScreenGallery(),
      },
    );
  }
}
