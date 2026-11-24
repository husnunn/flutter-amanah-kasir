import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/cart_controller.dart';
import 'discount_sheet.dart';

/// Panel pesanan: daftar item dengan stepper, subtotal, diskon, total, dan
/// tombol Bayar. Dipakai di kolom kanan tablet dan di bottom sheet HP.
class OrderPanel extends StatelessWidget {
  const OrderPanel({super.key, required this.cart, required this.onPay});

  final CartController cart;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) => Column(
        children: [
          _OrderHeader(cart: cart),
          Expanded(
            child: cart.isEmpty
                ? const StateView(
                    icon: AppIcons.shoppingBag,
                    title: 'Pesanan masih kosong',
                    message: 'Pilih produk di sebelah kiri untuk mulai.',
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    children: [
                      for (final line in cart.lines)
                        _OrderLine(line: line, cart: cart),
                    ],
                  ),
          ),
          _OrderTotals(cart: cart, onPay: onPay),
        ],
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.cart});

  final CartController cart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xxs,
              children: [
                Text('Pesanan', style: context.text.titleLarge),
                Text(
                  '${cart.productCount} produk · ${cart.itemCount} item',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Kosongkan',
            icon: AppIcons.trash,
            variant: AppButtonVariant.destructive,
            size: AppButtonSize.small,
            expand: false,
            onPressed: cart.isEmpty ? null : cart.clear,
          ),
        ],
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({required this.line, required this.cart});

  final CartLine line;
  final CartController cart;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final product = line.product;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          spacing: AppSpacing.sm,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatRupiah(line.subtotal),
                  style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatRupiah(product.price)} / item',
                  style: text.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                QtyStepper(
                  qty: line.qty,
                  itemName: product.name,
                  onDecrement: () => cart.decrement(product),
                  onIncrement: () => cart.increment(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTotals extends StatelessWidget {
  const _OrderTotals({required this.cart, required this.onPay});

  final CartController cart;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final muted = text.bodyMedium?.copyWith(color: context.app.ink3);
    final strong = text.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.app.surfaceAlt,
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: muted),
                  Text(formatRupiah(cart.subtotal), style: strong),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, AppSize.touch),
                    ),
                    onPressed: () => showDiscountSheet(context, cart),
                    child: Text(cart.discount > 0 ? 'Diskon' : 'Tambah diskon'),
                  ),
                  if (cart.discount > 0)
                    Text(
                      formatRupiahNegative(cart.discount),
                      style: strong?.copyWith(color: colors.error),
                    ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Total',
                    style: text.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(formatRupiah(cart.total), style: text.displaySmall),
                ],
              ),
              AppButton(
                label: 'Bayar ${formatRupiah(cart.total)}',
                onPressed: cart.isEmpty ? null : onPay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
