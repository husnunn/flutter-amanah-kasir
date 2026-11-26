import 'package:amanah_kasir/core/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Memuat Plus Jakarta Sans asli. Tanpa ini flutter_test memakai font Ahem
/// (tiap huruf selebar 1 em) sehingga overflow yang muncul tidak realistis.
Future<void> loadAppFonts() async {
  final loader = FontLoader(AppTypography.family);
  for (final w in [
    '400Regular',
    '500Medium',
    '600SemiBold',
    '700Bold',
    '800ExtraBold',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/PlusJakartaSans_$w.ttf'));
  }
  await loader.load();
}

/// Ukuran layar yang diuji (dp).
class Screens {
  static const phone = Size(390, 844);
  static const phoneSmall = Size(320, 640);
  static const tablet = Size(1280, 800);
  static const tabletSmall = Size(1024, 600);
}

/// Menampilkan [home] dalam MaterialApp bertema aplikasi pada [size].
/// Overflow/exception layout otomatis menggagalkan tes. [overrides] menimpa
/// provider Riverpod (mis. repositori contoh).
Future<void> pumpApp(
  WidgetTester tester,
  Widget home, {
  Size size = Screens.phone,
  double textScale = 1,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.light(), home: home),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

/// Seperti [pumpApp] tetapi mulai dari rute buatan (untuk menguji navigasi).
Future<void> pumpRoute(
  WidgetTester tester,
  Route<void> route, {
  Size size = Screens.tablet,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        onGenerateRoute: (_) => route,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}
