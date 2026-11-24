import 'package:material_ui/material_ui.dart';

import '../core/theme/theme.dart';
import '../dev/screen_gallery.dart';

/// Akar aplikasi: tema terang, bahasa Indonesia, halaman awal berupa galeri
/// layar. Dark mode belum ada di desain.
class AmanahKasirApp extends StatelessWidget {
  const AmanahKasirApp({super.key});

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
      home: const ScreenGallery(),
    );
  }
}
