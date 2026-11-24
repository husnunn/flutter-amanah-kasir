import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

enum BadgeTone { success, warning, info, neutral, danger }

/// Pil status kecil: hijau (Aktif, Tersinkron), amber (stok menipis, offline),
/// biru (Admin), abu-abu (Nonaktif, Kasir), merah.
class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.label, {
    super.key,
    this.tone = BadgeTone.success,
    this.showDot = false,
    this.rounded = false,
    this.large = false,
  });

  final String label;
  final BadgeTone tone;

  /// Titik berwarna di depan label (mis. "Tersinkron").
  final bool showDot;

  /// Sudut 6 px (badge role) alih-alih pil penuh.
  final bool rounded;

  /// Ukuran lebih besar untuk chip sinkron di header.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.app;
    final (background, foreground) = switch (tone) {
      BadgeTone.success => (colors.primaryContainer, colors.onPrimaryContainer),
      BadgeTone.warning => (app.warningSoft, app.warning),
      BadgeTone.info => (app.infoSoft, app.info),
      BadgeTone.neutral => (app.neutralSoft, app.ink2),
      BadgeTone.danger => (colors.errorContainer, colors.error),
    };
    final dotColor = switch (tone) {
      BadgeTone.success => colors.primary,
      BadgeTone.warning => app.warning,
      BadgeTone.info => app.info,
      BadgeTone.neutral => colors.onSurfaceVariant,
      BadgeTone.danger => colors.error,
    };
    final style = (large ? context.text.labelMedium : context.text.labelSmall)
        ?.copyWith(color: foreground, fontWeight: FontWeight.w700);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: rounded
            ? const BorderRadius.all(Radius.circular(AppRadius.sm - 4))
            : AppRadius.fullAll,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: large ? AppSpacing.md : AppSpacing.sm,
          vertical: large ? AppSpacing.xs : AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            if (showDot)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: AppSpacing.xs),
              ),
            Flexible(child: Text(label, style: style, maxLines: 1)),
          ],
        ),
      ),
    );
  }
}
