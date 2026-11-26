import 'package:amanah_kasir/features/auth/presentation/login_screen.dart';
import 'package:amanah_kasir/features/auth/presentation/pilih_toko_screen.dart';
import 'package:amanah_kasir/features/kasir/data/receipt_data.dart';
import 'package:amanah_kasir/features/kasir/presentation/kasir_screen.dart';
import 'package:amanah_kasir/features/kasir/presentation/pembayaran_screen.dart';
import 'package:amanah_kasir/features/kasir/presentation/transaksi_berhasil_screen.dart';
import 'package:amanah_kasir/features/kasir/state/cart_controller.dart';
import 'package:amanah_kasir/features/kasir/state/payment_controller.dart';
import 'package:amanah_kasir/features/keuangan/presentation/pengeluaran_screen.dart';
import 'package:amanah_kasir/features/laporan/presentation/dashboard_screen.dart';
import 'package:amanah_kasir/features/produk/data/product.dart';
import 'package:amanah_kasir/features/produk/presentation/produk_screen.dart';
import 'package:amanah_kasir/features/superadmin/data/sample_superadmin_data.dart';
import 'package:amanah_kasir/features/superadmin/presentation/toko_pengguna_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/superadmin_helpers.dart';
import 'helpers/test_app.dart';

CartController _cart() => CartController()..seedSample(sampleProducts);

Widget _receipt() {
  final cart = _cart();
  final payment = PaymentController(total: cart.total, initialReceived: 100000);
  return TransaksiBerhasilScreen(receipt: ReceiptData.from(cart, payment));
}

/// Setiap layar dari spesifikasi UI harus tampil tanpa overflow pada ukuran
/// desain, layar kecil, dan skala font 1,3x.
void main() {
  setUpAll(() async => TestWidgetsFlutterBinding.ensureInitialized());

  final screens = <String, Widget Function()>{
    'Login': () => const LoginScreen(),
    'Pilih toko': () => const PilihTokoScreen(),
    'Kasir': () => KasirScreen(cart: _cart()),
    'Pembayaran': () =>
        PembayaranScreen(cart: _cart(), initialReceived: 100000),
    'Transaksi berhasil': _receipt,
    'Dashboard': () => const DashboardScreen(),
    'Kelola produk': () => const ProdukScreen(),
    'Catat pengeluaran': () => const PengeluaranScreen(initialAmount: 150000),
    'Toko & pengguna': () =>
        const TokoPenggunaScreen(currentUid: sampleOwnerUid),
  };

  final sizes = <String, Size>{
    'HP 390x844': Screens.phone,
    'HP kecil 320x640': Screens.phoneSmall,
    'tablet 1280x800': Screens.tablet,
    'tablet kecil 1024x600': Screens.tabletSmall,
  };

  for (final screen in screens.entries) {
    for (final size in sizes.entries) {
      testWidgets('${screen.key} @ ${size.key}', (tester) async {
        await tester.runAsync(loadAppFonts);
        await pumpApp(
          tester,
          screen.value(),
          size: size.value,
          overrides: superadminOverrides(),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('${screen.key} @ HP dengan font 1,3x', (tester) async {
      await tester.runAsync(loadAppFonts);
      await pumpApp(
        tester,
        screen.value(),
        size: Screens.phone,
        textScale: 1.3,
        overrides: superadminOverrides(),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
