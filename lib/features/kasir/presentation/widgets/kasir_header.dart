import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Header kasir tablet: tanggal + nama kasir, nama toko, dan status sinkron.
class KasirTabletHeader extends StatelessWidget {
  const KasirTabletHeader({
    super.key,
    required this.dateLabel,
    required this.cashierName,
    required this.storeName,
  });

  final String dateLabel;
  final String cashierName;
  final String storeName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xxs,
          children: [
            Text(
              '$dateLabel · Kasir: $cashierName',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            Text(storeName, style: context.text.headlineMedium),
          ],
        ),
        const StatusBadge('Tersinkron', showDot: true, large: true),
      ],
    );
  }
}

/// Bagian atas header kasir HP: nama toko, kasir + status sinkron, printer.
class KasirPhoneHeader extends StatelessWidget {
  const KasirPhoneHeader({
    super.key,
    required this.cashierName,
    required this.storeName,
    required this.onPrinter,
  });

  final String cashierName;
  final String storeName;
  final VoidCallback onPrinter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meta = context.text.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.xxs,
            children: [
              Text(storeName, style: context.text.titleLarge),
              Row(
                spacing: AppSpacing.xs,
                children: [
                  Text('Kasir: $cashierName ·', style: meta),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: AppSpacing.xs - 1),
                  ),
                  Text('Tersinkron', style: meta),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Printer',
          onPressed: onPrinter,
          style: IconButton.styleFrom(
            minimumSize: const Size.square(AppSize.touch),
            side: BorderSide(color: colors.outline),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          color: context.app.ink2,
          icon: const AppIcon(AppIcons.printer),
        ),
      ],
    );
  }
}
