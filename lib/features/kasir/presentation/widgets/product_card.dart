import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../produk/data/product.dart';

/// Kartu produk untuk grid kasir tablet: blok inisial berwarna, nama, harga
/// hijau, stok. Produk yang ada di keranjang bergaris hijau + badge jumlah.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.qty,
    required this.onTap,
  });

  final Product product;
  final int qty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final inCart = qty > 0;
    final stockLabel = product.isLowStock
        ? 'Sisa ${product.stock}'
        : 'Stok ${product.stock}';

    return Semantics(
      button: true,
      label: '${product.name}, ${formatRupiah(product.price)}, $stockLabel',
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.sm),
        borderColor: inCart ? colors.primary : colors.outline,
        borderWidth: inCart ? AppSize.borderMedium : AppSize.borderThin,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.sm,
              children: [
                InitialBlock(
                  label: initialsOf(product.name),
                  tone: product.tone,
                  height: AppSize.productBlock,
                  style: text.headlineMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.xxs,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatRupiah(product.price),
                            style: text.titleSmall?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          Text(
                            stockLabel,
                            style: text.labelMedium?.copyWith(
                              color: product.isLowStock
                                  ? context.app.warning
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (inCart)
              Positioned(
                top: AppSpacing.xs,
                right: AppSpacing.xs,
                child: _QtyBadge(qty),
              ),
          ],
        ),
      ),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge(this.qty);

  final int qty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.fullAll,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppSize.badge,
          minHeight: AppSize.badge,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Center(
            widthFactor: 1,
            child: Text(
              '$qty',
              style: context.text.bodySmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
