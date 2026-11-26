import 'package:material_ui/material_ui.dart';

/// Skala spasi kelipatan 4. Jangan pakai angka di luar skala ini di widget.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Padding horizontal layar: HP 20, tablet 24 (spesifikasi UI).
  static const double screenPhone = lg;
  static const double screenTablet = xl;
}

/// Skala radius dari spesifikasi: field/tombol kecil 10-12, tombol utama 14,
/// kartu 16, kartu saldo/panel besar 20, chip penuh.
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;
  static const double sheet = 28;
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Ukuran komponen: ikon, tinggi kontrol, tebal garis.
abstract final class AppSize {
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 18;
  static const double icon = 20;
  static const double iconLg = 22;
  static const double iconXl = 24;
  static const double iconHero = 30;

  /// Area sentuh minimal.
  static const double touch = 44;
  static const double buttonLarge = 56;
  static const double buttonMedium = 48;
  static const double buttonSmall = 44;
  static const double field = 48;
  static const double fieldTall = 52;
  static const double fieldDense = 42;
  static const double amountField = 64;
  static const double chip = 36;
  static const double optionTall = 76;
  static const double badge = 26;
  static const double orderBar = 60;
  static const double productBlock = 72;
  static const double productRowBlock = 48;
  static const double keypadKey = 62;
  static const double progress = 6;
  static const double splitBar = 10;
  static const double legendDot = 9;

  static const double borderThin = 1;
  static const double borderMedium = 1.5;
  static const double borderThick = 2;
}

/// Ukuran layout besar (kolom, panel, bar) dari spesifikasi UI.
abstract final class AppLayout {
  /// Lebar >= ini memakai layout tablet (rail/sidebar + panel samping).
  static const double tabletBreakpoint = 900;

  static const double rail = 88;
  static const double sidebar = 240;
  static const double orderPanel = 380;
  static const double paymentSummary = 400;
  static const double paymentSummaryMin = 320;
  static const double filtersOneRow = 560;
  static const double keypad = 300;
  static const double editPanel = 340;
  static const double dialogWidth = 480;

  /// Tinggi minimal halaman kelola toko/pengguna; lebih pendek dari ini (mis.
  /// ponsel landscape) halaman digulir.
  static const double managementMinHeight = 620;
  static const double sideColumn = 320;
  static const double bottomNav = 68;
  static const double loginHero = 300;
  static const double phoneMaxContent = 480;
  static const double productGridExtent = 200;
  static const double dashboardMinHeight = 720;
  static const double phoneChartHeight = 190;
}

/// Durasi dan kurva animasi (token M3 bawaan Flutter).
abstract final class AppMotion {
  static const Duration fast = Durations.short3;
  static const Duration base = Durations.medium1;
  static const Duration slow = Durations.long1;
  static const Curve enter = Easing.emphasizedDecelerate;
  static const Curve exit = Easing.emphasizedAccelerate;
  static const Curve standard = Easing.standard;
}
