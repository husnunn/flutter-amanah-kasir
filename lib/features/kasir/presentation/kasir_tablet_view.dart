import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../produk/data/product.dart';
import '../state/cart_controller.dart';
import 'kasir_screen.dart';
import 'widgets/kasir_header.dart';
import 'widgets/order_panel.dart';
import 'widgets/product_card.dart';
import 'widgets/product_search_field.dart';

/// Kasir tablet landscape: rail 88 | produk | panel pesanan 380.
class KasirTabletView extends StatelessWidget {
  const KasirTabletView({
    super.key,
    required this.cart,
    required this.products,
    required this.category,
    required this.onCategory,
    required this.onQuery,
    required this.storeName,
    required this.cashierName,
    required this.dateLabel,
    required this.scanEnabled,
    required this.onPay,
    this.onLogout,
  });

  final CartController cart;
  final List<Product> products;
  final String category;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onQuery;
  final String storeName;
  final String cashierName;
  final String dateLabel;
  final bool scanEnabled;
  final VoidCallback onPay;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Row(
        children: [
          AppNavRail(
            items: kasirTabletNav,
            selectedIndex: 0,
            onSelected: (i) {
              if (i != 0) showComingSoon(context, kasirTabletNav[i].label);
            },
            userInitials: initialsOf(cashierName),
            onLogout: onLogout,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenTablet),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  KasirTabletHeader(
                    dateLabel: dateLabel,
                    cashierName: cashierName,
                    storeName: storeName,
                  ),
                  Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Expanded(child: ProductSearchField(onChanged: onQuery)),
                      if (scanEnabled)
                        AppButton(
                          label: 'Scan',
                          icon: AppIcons.scan,
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.medium,
                          expand: false,
                          onPressed: () =>
                              showComingSoon(context, 'Scan barcode'),
                        ),
                    ],
                  ),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final c in productCategories)
                        CategoryChip(
                          label: c,
                          selected: c == category,
                          onTap: () => onCategory(c),
                        ),
                    ],
                  ),
                  Expanded(
                    child: _ProductGrid(cart: cart, products: products),
                  ),
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(left: BorderSide(color: colors.outline)),
            ),
            child: SizedBox(
              width: AppLayout.orderPanel,
              child: OrderPanel(cart: cart, onPay: onPay),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.cart, required this.products});

  final CartController cart;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const StateView(
        icon: AppIcons.search,
        title: 'Produk tidak ditemukan',
        message: 'Coba kata kunci atau kategori lain.',
      );
    }
    // Tinggi kartu mengikuti skala font agar teks besar tidak terpotong.
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final extent =
        AppSize.productBlock +
        AppSpacing.xl +
        AppSpacing.sm +
        AppSpacing.xxxl * scale;
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) => GridView.builder(
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: AppLayout.productGridExtent,
          mainAxisExtent: extent,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemBuilder: (context, i) {
          final product = products[i];
          return ProductCard(
            product: product,
            qty: cart.qtyOf(product),
            onTap: () => cart.increment(product),
          );
        },
      ),
    );
  }
}
