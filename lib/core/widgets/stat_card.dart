import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'app_card.dart';

/// Kartu angka: label kecil, angka tebal, keterangan. [emphasized] = kartu
/// hijau penuh (saldo bersih). [compact] = varian ringkas untuk superadmin.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.valueSuffix,
    this.valueColor,
    this.emphasized = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final String? caption;

  /// Teks kecil di samping angka, mis. "dari 8".
  final String? valueSuffix;
  final Color? valueColor;
  final bool emphasized;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final muted = emphasized
        ? context.app.onAccentMuted
        : colors.onSurfaceVariant;
    final ink = emphasized
        ? colors.onPrimary
        : (valueColor ?? colors.onSurface);

    final valueStyle = (compact ? text.headlineLarge : text.headlineMedium)
        ?.copyWith(
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.4,
        );

    return AppCard(
      color: emphasized ? colors.primary : null,
      borderColor: emphasized ? colors.primary : null,
      radius: compact ? AppRadius.lgAll : AppRadius.xlAll,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.md : AppSpacing.lg,
        vertical: compact ? AppSpacing.sm : AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xxs,
        children: [
          Text(
            label,
            style: (compact ? text.labelMedium : text.bodySmall)?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text.rich(
            TextSpan(
              text: value,
              children: [
                if (valueSuffix != null)
                  TextSpan(
                    text: ' $valueSuffix',
                    style: text.bodySmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
              ],
            ),
            style: valueStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (caption != null)
            Text(caption!, style: text.labelMedium?.copyWith(color: muted)),
        ],
      ),
    );
  }
}
