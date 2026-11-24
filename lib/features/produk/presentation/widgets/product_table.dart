import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/product.dart';

/// Tabel produk (tablet): Produk | Kategori | Harga jual | Stok. Baris terpilih
/// berlatar hijau sangat muda; stok menipis berwarna amber.
class ProductTable extends StatelessWidget {
  const ProductTable({
    super.key,
    required this.products,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Product> products;
  final String? selectedId;
  final ValueChanged<Product> onSelect;

  static const int _flexProduct = 5;
  static const int _flexCategory = 2;
  static const int _flexPrice = 2;
  static const int _flexStock = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final head = context.text.labelMedium?.copyWith(color: context.app.ink3);
    Widget cell(int flex, String label, {TextAlign align = TextAlign.start}) =>
        Expanded(
          flex: flex,
          child: Text(label, textAlign: align, style: head),
        );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ColoredBox(
            color: context.app.surfaceAlt,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  cell(_flexProduct, 'Produk'),
                  cell(_flexCategory, 'Kategori'),
                  cell(_flexPrice, 'Harga jual', align: TextAlign.end),
                  cell(_flexStock, 'Stok', align: TextAlign.end),
                ],
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const StateView(
                    icon: AppIcons.package,
                    title: 'Produk tidak ditemukan',
                    message: 'Coba kata kunci atau filter lain.',
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, i) => _Row(
                      product: products[i],
                      selected: products[i].id == selectedId,
                      onTap: () => onSelect(products[i]),
                      divider: colors.outlineVariant,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.product,
    required this.selected,
    required this.onTap,
    required this.divider,
  });

  final Product product;
  final bool selected;
  final VoidCallback onTap;
  final Color divider;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final dim = product.isActive ? null : colors.onSurfaceVariant;
    final subtitle = [product.sku, ?product.barcode].join(' · ');

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? context.app.selectedRow : colors.surface,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: divider)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    flex: ProductTable._flexProduct,
                    child: Row(
                      spacing: AppSpacing.sm,
                      children: [
                        InitialBlock(
                          label: initialsOf(product.name),
                          tone: product.tone,
                          width: AppSize.chip + AppSpacing.xxs,
                          height: AppSize.chip + AppSpacing.xxs,
                          style: text.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodyMedium?.copyWith(
                                  color: dim,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                product.isActive
                                    ? subtitle
                                    : '$subtitle · Nonaktif',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: ProductTable._flexCategory,
                    child: Text(
                      product.category,
                      style: text.bodySmall?.copyWith(color: context.app.ink3),
                    ),
                  ),
                  Expanded(
                    flex: ProductTable._flexPrice,
                    child: Text(
                      formatRupiah(product.price),
                      textAlign: TextAlign.end,
                      style: text.bodySmall?.copyWith(
                        color: dim,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: ProductTable._flexStock,
                    child: Text(
                      '${product.stock}',
                      textAlign: TextAlign.end,
                      style: text.bodyMedium?.copyWith(
                        color: product.isLowStock ? context.app.warning : dim,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
