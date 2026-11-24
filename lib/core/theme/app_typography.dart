import 'package:material_ui/material_ui.dart';

/// Tipografi Plus Jakarta Sans (400-800) sesuai spesifikasi UI.
///
/// Semua gaya memakai angka tabular supaya nominal tidak bergeser saat berubah.
/// Pemetaan peran:
/// - displayLarge 30/800: total tagihan, kembalian, saldo bersih hero
/// - displayMedium 28/800: hero login, field nominal besar
/// - displaySmall 26/800: total di panel pesanan
/// - headlineLarge 24/800: judul besar HP ("Pilih toko")
/// - headlineMedium 22/700: judul layar; angka kartu statistik (w800)
/// - headlineSmall 20/700: judul header pembayaran, judul form
/// - titleLarge 18/700, titleMedium 16/700, titleSmall 15/700: judul panel/kartu
/// - bodyLarge 15/500: teks field; bodyMedium 14/500: isi; bodySmall 13/500
/// - labelLarge 16/700: teks tombol; labelMedium 12/600; labelSmall 11/600: navigasi
abstract final class AppTypography {
  static const String family = 'PlusJakartaSans';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static TextStyle _style(
    Color color,
    double size,
    FontWeight weight, {
    double tracking = 0,
    double height = 1.3,
  }) {
    return TextStyle(
      fontFamily: family,
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: tracking * size,
      height: height,
      fontFeatures: _tabular,
    );
  }

  static TextTheme textTheme(Color ink) {
    return TextTheme(
      displayLarge: _style(ink, 30, FontWeight.w800, tracking: -0.02),
      displayMedium: _style(ink, 28, FontWeight.w800, tracking: -0.02),
      displaySmall: _style(ink, 26, FontWeight.w800, tracking: -0.02),
      headlineLarge: _style(ink, 24, FontWeight.w800, tracking: -0.02),
      headlineMedium: _style(ink, 22, FontWeight.w700, tracking: -0.01),
      headlineSmall: _style(ink, 20, FontWeight.w700),
      titleLarge: _style(ink, 18, FontWeight.w700),
      titleMedium: _style(ink, 16, FontWeight.w700),
      titleSmall: _style(ink, 15, FontWeight.w700),
      bodyLarge: _style(ink, 15, FontWeight.w500, height: 1.45),
      bodyMedium: _style(ink, 14, FontWeight.w500, height: 1.4),
      bodySmall: _style(ink, 13, FontWeight.w500, height: 1.4),
      labelLarge: _style(ink, 16, FontWeight.w700),
      labelMedium: _style(ink, 12, FontWeight.w600),
      labelSmall: _style(ink, 11, FontWeight.w600),
    );
  }
}
