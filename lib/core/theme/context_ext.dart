import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Akses tema yang pendek: `context.colors`, `context.text`, `context.app`.
extension ThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;

  /// Warna di luar ColorScheme (ink2, warning, info, nada kategori, dst.).
  AppColors get app => Theme.of(this).extension<AppColors>()!;

  /// Layout tablet bila lebar jendela >= [AppLayout.tabletBreakpoint].
  bool get isTablet =>
      MediaQuery.sizeOf(this).width >= AppLayout.tabletBreakpoint;

  double get screenPadding =>
      isTablet ? AppSpacing.screenTablet : AppSpacing.screenPhone;

  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// Durasi animasi yang menghormati pengaturan "kurangi gerakan".
  Duration motion(Duration d) => reduceMotion ? Duration.zero : d;
}
