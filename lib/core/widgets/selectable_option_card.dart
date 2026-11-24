import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_card.dart';
import 'app_icon.dart';

/// Pilihan bergaya radio: metode bayar (dengan [icon] + centang) atau kategori
/// pengeluaran (hanya teks, di tengah). Terpilih = garis hijau + latar hijau muda.
class SelectableOptionCard extends StatelessWidget {
  const SelectableOptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.height = AppSize.optionTall,
    this.radius = AppRadius.lgAll,
    this.vertical = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final AppIconData? icon;
  final double height;
  final BorderRadius radius;

  /// Ikon di atas label (untuk lebar sempit), tanpa tanda centang.
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.onPrimaryContainer : context.app.ink2;
    final labelStyle =
        (icon != null ? context.text.titleSmall : context.text.bodySmall)
            ?.copyWith(
              color: foreground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: AppCard(
        onTap: onTap,
        radius: radius,
        padding: EdgeInsets.zero,
        color: selected ? colors.primaryContainer : colors.surface,
        borderColor: selected ? colors.primary : colors.outline,
        borderWidth: !selected
            ? AppSize.borderThin
            : (icon != null ? AppSize.borderThick : AppSize.borderMedium),
        child: SizedBox(
          height: height,
          child: icon == null
              ? Center(child: Text(label, style: labelStyle))
              : vertical
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.xxs,
                  children: [
                    AppIcon(icon!, size: AppSize.iconLg, color: foreground),
                    Text(label, style: labelStyle, maxLines: 1),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    spacing: AppSpacing.sm,
                    children: [
                      AppIcon(icon!, size: AppSize.iconXl, color: foreground),
                      Expanded(
                        child: Text(label, style: labelStyle, maxLines: 1),
                      ),
                      if (selected)
                        AppIcon(
                          AppIcons.check,
                          color: foreground,
                          strokeWidth: 2.2,
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
