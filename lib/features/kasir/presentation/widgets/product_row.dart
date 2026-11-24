import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../produk/data/product.dart';

/// Baris produk untuk daftar kasir HP. Belum di keranjang: tombol +;
/// sudah di keranjang: stepper jumlah.
class ProductRow extends StatelessWidget {
  const ProductRow({
    super.key,
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final Product product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.app.track)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          spacing: AppSpacing.sm,
          children: [
            InitialBlock(
              label: initialsOf(product.name),
              tone: product.tone,
              width: AppSize.productRowBlock,
              height: AppSize.productRowBlock,
              radius: AppRadius.mdAll,
            ),
            Expanded(
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
                  Wrap(
                    spacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatRupiah(product.price),
                        style: text.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        product.isLowStock
                            ? 'Sisa ${product.stock}'
                            : 'Stok ${product.stock}',
                        style: text.labelMedium?.copyWith(
                          color: product.isLowStock
                              ? context.app.warning
                              : colors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (qty > 0)
              QtyStepper(
                qty: qty,
                itemName: product.name,
                onDecrement: onRemove,
                onIncrement: onAdd,
              )
            else
              Semantics(
                button: true,
                label: 'Tambah ${product.name} ke pesanan',
                child: AppCard(
                  onTap: onAdd,
                  radius: AppRadius.mdAll,
                  padding: EdgeInsets.zero,
                  child: SizedBox.square(
                    dimension: AppSize.touch,
                    child: Center(
                      child: AppIcon(
                        AppIcons.plus,
                        size: AppSize.iconMd,
                        color: colors.primary,
                        strokeWidth: 2.2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
