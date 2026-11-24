import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Blok inisial berwarna lembut (pengganti foto produk / kode toko).
class InitialBlock extends StatelessWidget {
  const InitialBlock({
    super.key,
    required this.label,
    required this.tone,
    this.width,
    this.height,
    this.radius = AppRadius.smAll,
    this.style,
  });

  final String label;
  final ToneName tone;
  final double? width;
  final double? height;
  final BorderRadius radius;

  /// Gaya teks; default `titleMedium` (16/700).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = context.app.tone(tone);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.soft, borderRadius: radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            style: (style ?? context.text.titleMedium)?.copyWith(
              color: colors.strong,
            ),
          ),
        ),
      ),
    );
  }
}
