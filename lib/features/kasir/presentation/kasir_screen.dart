import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/widgets.dart';
import '../../produk/data/product.dart';
import '../state/cart_controller.dart';
import 'kasir_phone_view.dart';
import 'kasir_tablet_view.dart';

const kasirTabletNav = <NavItem>[
  NavItem(icon: AppIcons.shoppingBag, label: 'Kasir'),
  NavItem(icon: AppIcons.receipt, label: 'Riwayat'),
  NavItem(icon: AppIcons.printer, label: 'Printer'),
];

const kasirPhoneNav = <NavItem>[
  NavItem(icon: AppIcons.shoppingBag, label: 'Kasir'),
  NavItem(icon: AppIcons.receipt, label: 'Riwayat'),
  NavItem(icon: AppIcons.user, label: 'Akun'),
];

/// Layar kasir: grid produk + panel pesanan (tablet) atau daftar produk + bar
/// pesanan dengan keranjang di bottom sheet (HP). Satu state untuk keduanya.
class KasirScreen extends StatefulWidget {
  const KasirScreen({
    super.key,
    required this.cart,
    this.products = sampleProducts,
    this.storeName = 'Toko Berkah Jaya',
    this.cashierName = 'Rina',
    this.dateLabel = 'Selasa, 24 Nov 2026',
    this.scanEnabled = true,
    this.onPay,
    this.onLogout,
  });

  final CartController cart;
  final List<Product> products;
  final String storeName;
  final String cashierName;
  final String dateLabel;

  /// Tombol scan hanya muncul bila diaktifkan di pengaturan toko (PRD F-03).
  final bool scanEnabled;
  final VoidCallback? onPay;
  final VoidCallback? onLogout;

  @override
  State<KasirScreen> createState() => _KasirScreenState();
}

class _KasirScreenState extends State<KasirScreen> {
  String _category = productCategories.first;
  String _query = '';

  List<Product> get _filtered {
    final q = _query.trim().toLowerCase();
    return widget.products.where((p) {
      if (!p.isActive) return false;
      final inCategory =
          _category == productCategories.first || p.category == _category;
      final matches =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          (p.barcode?.contains(q) ?? false);
      return inCategory && matches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filtered;
    void onPay() => widget.onPay?.call();

    return ResponsiveLayout(
      tablet: (_) => KasirTabletView(
        cart: widget.cart,
        products: products,
        category: _category,
        onCategory: (c) => setState(() => _category = c),
        onQuery: (q) => setState(() => _query = q),
        storeName: widget.storeName,
        cashierName: widget.cashierName,
        dateLabel: widget.dateLabel,
        scanEnabled: widget.scanEnabled,
        onPay: onPay,
        onLogout: widget.onLogout,
      ),
      phone: (_) => KasirPhoneView(
        cart: widget.cart,
        products: products,
        category: _category,
        onCategory: (c) => setState(() => _category = c),
        onQuery: (q) => setState(() => _query = q),
        storeName: widget.storeName,
        cashierName: widget.cashierName,
        scanEnabled: widget.scanEnabled,
        onPay: onPay,
      ),
    );
  }
}
