import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/dashboard_data.dart';

/// Produk terlaris: nama, jumlah terjual, dan bar progres relatif ke juara.
class TopProductsCard extends StatelessWidget {
  const TopProductsCard({super.key, required this.products});

  final List<TopProduct> products;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final best = products.isEmpty ? 1 : products.first.sold;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.sm,
        children: [
          Text('Produk terlaris', style: text.titleSmall),
          for (final p in products)
            Column(
              spacing: AppSpacing.xs,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: AppSpacing.sm,
                  children: [
                    Flexible(
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${formatNumber(p.sold)} terjual',
                      style: text.bodySmall?.copyWith(color: context.app.ink3),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: p.sold / best,
                  minHeight: AppSize.progress,
                  borderRadius: AppRadius.fullAll,
                  backgroundColor: context.colors.outlineVariant,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Stok menipis: produk di bawah batas minimum, "Sisa x / min y".
class LowStockCard extends StatelessWidget {
  const LowStockCard({super.key, required this.items});

  final List<LowStockItem> items;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Stok menipis', style: text.titleSmall),
              StatusBadge('${items.length} produk', tone: BadgeTone.warning),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < items.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: i == items.length - 1
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: context.colors.outlineVariant,
                        ),
                      ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: AppSpacing.sm,
                  children: [
                    Flexible(
                      child: Text(
                        items[i].name,
                        style: text.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Sisa ${items[i].stock} / min ${items[i].minStock}',
                      style: text.labelMedium?.copyWith(
                        color: context.app.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
