import 'package:material_ui/material_ui.dart';

/// Nama pasangan warna lembut untuk blok inisial produk/toko (pengganti foto).
enum ToneName { green, amber, blue, rose, violet, slate }

@immutable
class ToneColors {
  const ToneColors({required this.soft, required this.strong});

  /// Latar lembut.
  final Color soft;

  /// Huruf/ikon tebal di atas [soft].
  final Color strong;
}

/// Warna di luar ColorScheme (token spesifikasi UI). Hex hanya ada di sini.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ink2,
    required this.ink3,
    required this.accentMuted,
    required this.onAccentMuted,
    required this.surfaceAlt,
    required this.borderInput,
    required this.track,
    required this.selectedRow,
    required this.neutralSoft,
    required this.warning,
    required this.warningSoft,
    required this.warningBorder,
    required this.info,
    required this.infoSoft,
    required this.dangerBorder,
    required this.tones,
  });

  final Color ink2;
  final Color ink3;
  final Color accentMuted;
  final Color onAccentMuted;
  final Color surfaceAlt;
  final Color borderInput;
  final Color track;
  final Color selectedRow;
  final Color neutralSoft;
  final Color warning;
  final Color warningSoft;
  final Color warningBorder;
  final Color info;
  final Color infoSoft;
  final Color dangerBorder;
  final Map<ToneName, ToneColors> tones;

  ToneColors tone(ToneName name) => tones[name]!;

  static const light = AppColors(
    ink2: Color(0xFF344054),
    ink3: Color(0xFF475467),
    accentMuted: Color(0xFFA8D8CA),
    onAccentMuted: Color(0xFFCDEBE2),
    surfaceAlt: Color(0xFFF9FAFB),
    borderInput: Color(0xFFD0D5DD),
    track: Color(0xFFE9EBEF),
    selectedRow: Color(0xFFF0F8F5),
    neutralSoft: Color(0xFFF2F4F7),
    warning: Color(0xFFB54708),
    warningSoft: Color(0xFFFEF3E2),
    warningBorder: Color(0xFFF5D9B5),
    info: Color(0xFF175CD3),
    infoSoft: Color(0xFFEAF2FF),
    dangerBorder: Color(0xFFF4C7C3),
    tones: {
      ToneName.green: ToneColors(
        soft: Color(0xFFE6F4EF),
        strong: Color(0xFF0B7A62),
      ),
      ToneName.amber: ToneColors(
        soft: Color(0xFFFEF3E2),
        strong: Color(0xFFB54708),
      ),
      ToneName.blue: ToneColors(
        soft: Color(0xFFEAF2FF),
        strong: Color(0xFF175CD3),
      ),
      ToneName.rose: ToneColors(
        soft: Color(0xFFFDECEE),
        strong: Color(0xFFC01048),
      ),
      ToneName.violet: ToneColors(
        soft: Color(0xFFF1EEFE),
        strong: Color(0xFF5925DC),
      ),
      ToneName.slate: ToneColors(
        soft: Color(0xFFEEF0F3),
        strong: Color(0xFF344054),
      ),
    },
  );

  @override
  AppColors copyWith({
    Color? ink2,
    Color? ink3,
    Color? accentMuted,
    Color? onAccentMuted,
    Color? surfaceAlt,
    Color? borderInput,
    Color? track,
    Color? selectedRow,
    Color? neutralSoft,
    Color? warning,
    Color? warningSoft,
    Color? warningBorder,
    Color? info,
    Color? infoSoft,
    Color? dangerBorder,
    Map<ToneName, ToneColors>? tones,
  }) {
    return AppColors(
      ink2: ink2 ?? this.ink2,
      ink3: ink3 ?? this.ink3,
      accentMuted: accentMuted ?? this.accentMuted,
      onAccentMuted: onAccentMuted ?? this.onAccentMuted,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      borderInput: borderInput ?? this.borderInput,
      track: track ?? this.track,
      selectedRow: selectedRow ?? this.selectedRow,
      neutralSoft: neutralSoft ?? this.neutralSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      warningBorder: warningBorder ?? this.warningBorder,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      dangerBorder: dangerBorder ?? this.dangerBorder,
      tones: tones ?? this.tones,
    );
  }

  /// Hanya ada satu varian (light); transisi tema cukup berpindah di titik tengah.
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}
