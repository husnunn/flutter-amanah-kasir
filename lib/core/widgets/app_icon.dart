import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';

/// Ikon garis dari [AppIcons]. Warna mengikuti [color], lalu `IconTheme`
/// (jadi otomatis ikut warna tombol), lalu warna teks utama.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppSize.icon,
    this.color,
    this.strokeWidth = 1.8,
    this.semanticLabel,
  });

  final AppIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tint =
        color ?? IconTheme.of(context).color ?? context.colors.onSurface;
    return SvgPicture.string(
      icon.svg(strokeWidth),
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );
  }
}
