import 'package:material_ui/material_ui.dart';

import '../core/utils/coming_soon.dart';
import '../features/admin/presentation/admin_nav.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/pilih_toko_screen.dart';
import '../features/keuangan/presentation/pengeluaran_screen.dart';
import '../features/kasir/data/receipt_data.dart';
import '../features/kasir/presentation/kasir_screen.dart';
import '../features/kasir/presentation/pembayaran_screen.dart';
import '../features/kasir/presentation/transaksi_berhasil_screen.dart';
import '../features/kasir/state/cart_controller.dart';
import '../features/kasir/state/payment_controller.dart';
import '../features/laporan/presentation/dashboard_screen.dart';
import '../features/produk/data/product.dart';
import '../features/produk/presentation/produk_screen.dart';
import '../features/superadmin/presentation/toko_pengguna_screen.dart';

typedef _PageBuilder = Widget Function(BuildContext context);

/// Alur antar layar mengikuti peta layar di spesifikasi UI:
/// Login -> Pilih toko -> Dashboard; Kasir -> Pembayaran -> Transaksi berhasil
/// -> Kasir. Belum ada auth sungguhan, jadi peran tidak dicek di sini.
class AppRouter {
  const AppRouter();

  static const String kasirRouteName = '/kasir';

  Route<void> _route(_PageBuilder builder, {String? name}) =>
      MaterialPageRoute<void>(
        settings: RouteSettings(name: name),
        builder: builder,
      );

  CartController _newCart({required bool seeded}) {
    final cart = CartController();
    if (seeded) cart.seedSample(sampleProducts);
    return cart;
  }

  void _toLogin(BuildContext context) =>
      Navigator.of(context).pushAndRemoveUntil(login(), (r) => r.isFirst);

  // --- Masuk -----------------------------------------------------------------

  Route<void> login() => _route(
    (c) => LoginScreen(
      onSubmit: () => Navigator.of(c).pushReplacement(pilihToko()),
    ),
  );

  Route<void> pilihToko() => _route(
    (c) => PilihTokoScreen(
      onConfirm: (_) => Navigator.of(c).pushReplacement(dashboard()),
    ),
  );

  // --- Kasir -----------------------------------------------------------------

  /// [seeded] true mengisi keranjang dengan contoh seperti di desain.
  Route<void> kasir({bool seeded = true}) {
    final cart = _newCart(seeded: seeded);
    return _route(
      name: kasirRouteName,
      (c) => KasirScreen(
        cart: cart,
        onPay: () => Navigator.of(c).push(pembayaran(cart)),
        onLogout: () => _toLogin(c),
      ),
    );
  }

  Route<void> pembayaran(CartController cart, {int initialReceived = 0}) =>
      _route(
        (c) => PembayaranScreen(
          cart: cart,
          initialReceived: initialReceived,
          onFinish: (receipt) =>
              Navigator.of(c).push(transaksiBerhasil(cart, receipt)),
        ),
      );

  Route<void> transaksiBerhasil(CartController cart, ReceiptData receipt) =>
      _route(
        (c) => TransaksiBerhasilScreen(
          receipt: receipt,
          onNewTransaction: () {
            cart.clear();
            Navigator.of(
              c,
            ).popUntil((r) => r.settings.name == kasirRouteName || r.isFirst);
          },
        ),
      );

  /// Pembayaran dengan isian contoh (uang diterima Rp 100.000), untuk galeri.
  Route<void> pembayaranContoh() =>
      pembayaran(_newCart(seeded: true), initialReceived: 100000);

  /// Layar transaksi berhasil dengan nota contoh, untuk galeri.
  Route<void> transaksiBerhasilContoh() {
    final cart = _newCart(seeded: true);
    final payment = PaymentController(
      total: cart.total,
      initialReceived: 100000,
    );
    return transaksiBerhasil(cart, ReceiptData.from(cart, payment));
  }

  // --- Admin -----------------------------------------------------------------

  void _goAdmin(
    BuildContext c,
    AdminDestination target,
    AdminDestination from,
  ) {
    if (target == from) return;
    final navigator = Navigator.of(c);
    switch (target) {
      case AdminDestination.dashboard:
        navigator.pushReplacement(dashboard());
      case AdminDestination.produk:
        navigator.pushReplacement(produk());
      case AdminDestination.kasir:
        navigator.push(kasir(seeded: false));
      case AdminDestination.pengeluaran:
        navigator.push(pengeluaran());
      case AdminDestination.laporan ||
          AdminDestination.riwayat ||
          AdminDestination.kasirShift ||
          AdminDestination.pengaturan:
        showComingSoon(c, adminSidebarItems[target.index].label);
    }
  }

  Route<void> dashboard() => _route(
    (c) => DashboardScreen(
      onNavigate: (d) => _goAdmin(c, d, AdminDestination.dashboard),
      onSwitchStore: () => Navigator.of(c).pushReplacement(pilihToko()),
      onLogout: () => _toLogin(c),
    ),
  );

  Route<void> produk() => _route(
    (c) => ProdukScreen(
      onNavigate: (d) => _goAdmin(c, d, AdminDestination.produk),
      onSwitchStore: () => Navigator.of(c).pushReplacement(pilihToko()),
    ),
  );

  Route<void> pengeluaran({bool prefilled = false}) => _route(
    (c) => PengeluaranScreen(
      initialAmount: prefilled ? 150000 : null,
      initialNote: prefilled ? 'Beli telur 5 kg dan roti tawar di pasar' : null,
    ),
  );

  // --- Superadmin ------------------------------------------------------------

  Route<void> tokoPengguna() =>
      _route((c) => TokoPenggunaScreen(onLogout: () => _toLogin(c)));
}
