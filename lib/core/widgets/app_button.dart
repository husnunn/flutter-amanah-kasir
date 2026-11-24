import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_icon.dart';

enum AppButtonVariant { primary, secondary, destructive }

enum AppButtonSize { large, medium, small }

/// Tombol sesuai spesifikasi: utama (hijau), sekunder (putih bergaris),
/// destruktif (putih, garis merah muda). Tinggi: large 56, medium 48, small 44.
///
/// Dengan [expand] true tombol selebar induknya; di dalam `Row` bungkus dengan
/// `Expanded` atau set `expand: false`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppIconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final height = switch (size) {
      AppButtonSize.large => AppSize.buttonLarge,
      AppButtonSize.medium => AppSize.buttonMedium,
      AppButtonSize.small => AppSize.buttonSmall,
    };
    final base = size == AppButtonSize.large
        ? text.labelLarge
        : text.bodyMedium;
    final weight = variant == AppButtonVariant.primary
        ? FontWeight.w700
        : FontWeight.w600;
    final padding = EdgeInsets.symmetric(
      horizontal: size == AppButtonSize.large ? AppSpacing.xl : AppSpacing.md,
    );
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        if (icon != null) AppIcon(icon!, size: AppSize.iconMd),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    final minimumSize = Size(expand ? double.infinity : 64, height);
    final textStyle = base?.copyWith(fontWeight: weight);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          textStyle: textStyle,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          textStyle: textStyle,
        ),
        child: child,
      ),
      AppButtonVariant.destructive => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: minimumSize,
          padding: padding,
          textStyle: textStyle,
          foregroundColor: context.colors.error,
          side: BorderSide(color: context.app.dangerBorder),
        ),
        child: child,
      ),
    };
  }
}
