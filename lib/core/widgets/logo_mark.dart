import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

enum LogoSize { sm, md, lg }

/// Logo aplikasi: huruf "K" putih di kotak hijau (atau kebalikannya di hero).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = LogoSize.md, this.inverted = false});

  final LogoSize size;

  /// Kotak putih dengan huruf hijau, untuk di atas latar hijau.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final (box, radius, style) = switch (size) {
      LogoSize.sm => (36.0, AppRadius.sm, text.titleMedium),
      LogoSize.md => (44.0, AppRadius.md, text.headlineSmall),
      LogoSize.lg => (56.0, AppRadius.xl, text.displaySmall),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: inverted ? colors.surface : colors.primary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox.square(
        dimension: box,
        child: Center(
          child: Text(
            'K',
            style: style?.copyWith(
              color: inverted ? colors.primary : colors.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
