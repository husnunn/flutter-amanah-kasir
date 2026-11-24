import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Merakit ThemeData dari token spesifikasi UI (hijau toska, latar abu muda,
/// kartu putih). Baru ada varian terang; dark mode belum ada di desain.
abstract final class AppTheme {
  static const ColorScheme _lightScheme = ColorScheme.light(
    primary: Color(0xFF0B7A62),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE6F4EF),
    onPrimaryContainer: Color(0xFF075E4B),
    secondary: Color(0xFF101828),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEEF0F3),
    onSecondaryContainer: Color(0xFF344054),
    tertiary: Color(0xFF175CD3),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFEAF2FF),
    onTertiaryContainer: Color(0xFF175CD3),
    error: Color(0xFFB42318),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEF3F2),
    onErrorContainer: Color(0xFFB42318),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF101828),
    onSurfaceVariant: Color(0xFF5B6474),
    outline: Color(0xFFE4E7EC),
    outlineVariant: Color(0xFFEEF0F3),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF9FAFB),
    surfaceContainer: Color(0xFFF4F5F7),
    surfaceContainerHigh: Color(0xFFE9EBEF),
    surfaceContainerHighest: Color(0xFFEEF0F3),
    inverseSurface: Color(0xFF101828),
    onInverseSurface: Color(0xFFFFFFFF),
    surfaceTint: Color(0x00000000),
  );

  static ThemeData light() => _build(_lightScheme, AppColors.light);

  static ThemeData _build(ColorScheme scheme, AppColors extra) {
    final text = AppTypography.textTheme(scheme.onSurface);
    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: extra.borderInput),
    );

    return ThemeData(
      colorScheme: scheme,
      textTheme: text,
      fontFamily: AppTypography.family,
      scaffoldBackgroundColor: scheme.surfaceContainer,
      extensions: [extra],
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: const Color(0x00000000),
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: const Color(0x00000000),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, AppSize.buttonLarge),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, AppSize.buttonLarge),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          foregroundColor: extra.ink2,
          backgroundColor: scheme.surface,
          side: BorderSide(color: scheme.outline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(
            color: scheme.primary,
            width: AppSize.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: text.bodyMedium?.copyWith(color: extra.ink2),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: AppSize.borderThin,
        space: AppSize.borderThin,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: const Color(0x00000000),
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.secondary,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSecondary),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: const Color(0x00000000),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxlAll),
        titleTextStyle: text.titleLarge,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.onPrimary),
        trackOutlineColor: const WidgetStatePropertyAll(Color(0x00000000)),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : extra.borderInput,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surface,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: extra.borderInput, width: AppSize.borderMedium),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
