import 'package:material_ui/material_ui.dart';

import '../core/utils/coming_soon.dart';
import '../features/admin/presentation/admin_nav.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/pilih_toko_screen.dart';
import '../features/kasir/data/receipt_data.dart';
import '../features/kasir/presentation/kasir_screen.dart';
import '../features/kasir/presentation/pembayaran_screen.dart';
import '../features/kasir/presentation/transaksi_berhasil_screen.dart';
import '../features/kasir/state/cart_controller.dart';
import '../features/kasir/state/payment_controller.dart';
import '../features/keuangan/presentation/pengeluaran_screen.dart';
import '../features/laporan/presentation/dashboard_screen.dart';
import '../features/produk/data/product.dart';
import '../features/produk/presentation/produk_screen.dart';
import '../features/superadmin/presentation/toko_pengguna_screen.dart';

typedef _PageBuilder = Widget Function(BuildContext context);

/// Alur antar layar mengikuti peta layar di spesifikasi UI:
/// Login -> Pilih toko -> Dashboard; Kasir -> Pembayaran -> Transaksi berhasil
/// -> Kasir.
///
/// Dua mode pemakaian:
/// - Galeri UI (`const AppRouter()`): data contoh, Login/Pilih toko hanya
///   berpindah layar.
/// - Aplikasi sungguhan: `AuthGate` mengisi [onLogout], [onSwitchStore], dan
///   identitas pengguna/toko dari sesi Firebase.
class AppRouter {
  const AppRouter({
    this.onLogout,
    this.onSwitchStore,
    this.userName = 'Sari Ayu',
    this.storeName = 'Toko Berkah Jaya',
    this.storeCount = 3,
  });

  /// Menutup sesi. Null = perilaku galeri (kembali ke layar Login contoh).
  final VoidCallback? onLogout;

  /// Kembali ke pemilihan toko. Null = perilaku galeri.
  final VoidCallback? onSwitchStore;

  final String userName;
  final String storeName;
  final int storeCount;

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

  void _logout(BuildContext context) {
    final hook = onLogout;
    if (hook != null) return hook();
    Navigator.of(context).pushAndRemoveUntil(login(), (r) => r.isFirst);
  }

  void _switchStore(BuildContext context) {
    final hook = onSwitchStore;
    if (hook != null) return hook();
    Navigator.of(context).pushReplacement(pilihToko());
  }

  // --- Halaman (dipakai gerbang sebagai layar awal dan oleh rute di bawah) ---

  Widget kasirPage(BuildContext context, CartController cart) => KasirScreen(
    cart: cart,
    storeName: storeName,
    cashierName: userName,
    onPay: () => Navigator.of(context).push(pembayaran(cart)),
    onLogout: () => _logout(context),
  );

  Widget dashboardPage(BuildContext context) => DashboardScreen(
    storeName: storeName,
    storeCount: storeCount,
    userName: userName,
    onNavigate: (d) => _goAdmin(context, d, AdminDestination.dashboard),
    onSwitchStore: () => _switchStore(context),
    onLogout: () => _logout(context),
  );

  Widget produkPage(BuildContext context) => ProdukScreen(
    storeName: storeName,
    storeCount: storeCount,
    userName: userName,
    onNavigate: (d) => _goAdmin(context, d, AdminDestination.produk),
    onSwitchStore: () => _switchStore(context),
  );

  Widget tokoPenggunaPage(BuildContext context) =>
      TokoPenggunaScreen(onLogout: () => _logout(context));

  // --- Masuk -----------------------------------------------------------------

  Route<void> login() => _route(
    (c) => LoginScreen(
      onSubmit: (_, _) => Navigator.of(c).pushReplacement(pilihToko()),
      onForgotPassword: () => showComingSoon(c, 'Lupa password'),
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
    return _route(name: kasirRouteName, (c) => kasirPage(c, cart));
  }

  Route<void> pembayaran(CartController cart, {int initialReceived = 0}) =>
      _route(
        (c) => PembayaranScreen(
          cart: cart,
          storeName: storeName,
          cashierName: userName,
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

  Route<void> dashboard() => _route(dashboardPage);

  Route<void> produk() => _route(produkPage);

  Route<void> pengeluaran({bool prefilled = false}) => _route(
    (c) => PengeluaranScreen(
      storeName: storeName,
      initialAmount: prefilled ? 150000 : null,
      initialNote: prefilled ? 'Beli telur 5 kg dan roti tawar di pasar' : null,
    ),
  );

  // --- Superadmin ------------------------------------------------------------

  Route<void> tokoPengguna() => _route(tokoPenggunaPage);
}
