import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/widgets/widgets.dart';
import '../../produk/data/product.dart';
import '../state/cart_controller.dart';
import 'kasir_screen.dart';
import 'widgets/kasir_header.dart';
import 'widgets/order_bar.dart';
import 'widgets/order_panel.dart';
import 'widgets/product_row.dart';
import 'widgets/product_search_field.dart';

/// Kasir HP portrait: header + pencarian + chip, daftar produk, bar pesanan,
/// navigasi bawah. "Lihat pesanan" membuka keranjang sebagai bottom sheet.
class KasirPhoneView extends StatelessWidget {
  const KasirPhoneView({
    super.key,
    required this.cart,
    required this.products,
    required this.category,
    required this.onCategory,
    required this.onQuery,
    required this.storeName,
    required this.cashierName,
    required this.scanEnabled,
    required this.onPay,
  });

  final CartController cart;
  final List<Product> products;
  final String category;
  final ValueChanged<String> onCategory;
  final ValueChanged<String> onQuery;
  final String storeName;
  final String cashierName;
  final bool scanEnabled;
  final VoidCallback onPay;

  void _openOrder(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.85,
        child: OrderPanel(
          cart: cart,
          onPay: () {
            Navigator.of(sheetContext).pop();
            onPay();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(bottom: BorderSide(color: colors.outline)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPhone,
                  AppSpacing.lg,
                  AppSpacing.screenPhone,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md,
                  children: [
                    KasirPhoneHeader(
                      cashierName: cashierName,
                      storeName: storeName,
                      onPrinter: () =>
                          showComingSoon(context, 'Pengaturan printer'),
                    ),
                    ProductSearchField(
                      phone: true,
                      onChanged: onQuery,
                      onScan: scanEnabled
                          ? () => showComingSoon(context, 'Scan barcode')
                          : null,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: AppSpacing.xs,
                        children: [
                          for (final c in productCategories)
                            CategoryChip(
                              label: c,
                              selected: c == category,
                              onTap: () => onCategory(c),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const StateView(
                    icon: AppIcons.search,
                    title: 'Produk tidak ditemukan',
                    message: 'Coba kata kunci atau kategori lain.',
                  )
                : ListenableBuilder(
                    listenable: cart,
                    builder: (context, _) => ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPhone,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        final product = products[i];
                        return ProductRow(
                          product: product,
                          qty: cart.qtyOf(product),
                          onAdd: () => cart.increment(product),
                          onRemove: () => cart.decrement(product),
                        );
                      },
                    ),
                  ),
          ),
          OrderBar(cart: cart, onTap: () => _openOrder(context)),
          AppBottomNav(
            items: kasirPhoneNav,
            currentIndex: 0,
            onTap: (i) {
              if (i != 0) showComingSoon(context, kasirPhoneNav[i].label);
            },
          ),
        ],
      ),
    );
  }
}
