import 'package:amanah_kasir/app/app.dart';
import 'package:amanah_kasir/app/app_router.dart';
import 'package:amanah_kasir/core/firebase/firebase_bootstrap.dart';
import 'package:amanah_kasir/features/auth/presentation/setup_needed_screen.dart';
import 'package:amanah_kasir/features/kasir/presentation/widgets/product_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  setUpAll(() async => TestWidgetsFlutterBinding.ensureInitialized());

  testWidgets('alur kasir tablet: bayar -> nota -> transaksi baru', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    await pumpRoute(tester, const AppRouter().kasir());

    expect(find.text('Bayar Rp 58.500'), findsOneWidget);
    await tester.tap(find.text('Bayar Rp 58.500'));
    await tester.pumpAndSettle();

    expect(find.text('Pembayaran'), findsOneWidget);
    // Uang belum cukup: tombol selesai nonaktif.
    final finish = find.widgetWithText(FilledButton, 'Selesaikan & cetak nota');
    expect(tester.widget<FilledButton>(finish).onPressed, isNull);

    await tester.tap(find.text('Uang pas'));
    await tester.pump();
    expect(tester.widget<FilledButton>(finish).onPressed, isNotNull);

    await tester.tap(finish);
    await tester.pumpAndSettle();
    expect(find.text('Transaksi berhasil'), findsOneWidget);

    await tester.tap(find.text('Transaksi baru'));
    await tester.pumpAndSettle();
    // Kembali ke kasir dengan keranjang kosong.
    expect(find.text('Pesanan masih kosong'), findsOneWidget);
  });

  testWidgets('kasir HP: keranjang jadi bottom sheet lalu ke pembayaran', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    await pumpRoute(tester, const AppRouter().kasir(), size: Screens.phone);

    expect(find.text('Lihat pesanan'), findsOneWidget);
    await tester.tap(find.text('Lihat pesanan'));
    await tester.pumpAndSettle();
    expect(find.text('Pesanan'), findsOneWidget);

    await tester.tap(find.text('Bayar Rp 58.500'));
    await tester.pumpAndSettle();
    expect(find.text('Pembayaran'), findsOneWidget);
  });

  testWidgets('cari dan filter kategori memengaruhi grid produk', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    await pumpRoute(tester, const AppRouter().kasir(seeded: false));

    expect(find.byType(ProductCard), findsNWidgets(12));
    await tester.enterText(find.byType(TextField).first, 'kopi');
    await tester.pump();
    expect(find.byType(ProductCard), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();
    await tester.tap(find.text('Minuman'));
    await tester.pump();
    expect(find.byType(ProductCard), findsNWidgets(4));
  });

  testWidgets('mengetuk produk menambah ke pesanan', (tester) async {
    await tester.runAsync(loadAppFonts);
    await pumpRoute(tester, const AppRouter().kasir(seeded: false));

    expect(find.text('Pesanan masih kosong'), findsOneWidget);
    await tester.tap(find.byType(ProductCard).first);
    await tester.pump();
    expect(find.text('Pesanan masih kosong'), findsNothing);
    expect(find.text('1 produk · 1 item'), findsOneWidget);
  });

  testWidgets('galeri membuka layar login', (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = Screens.phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AmanahKasirApp());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Amanah Kasir'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Login'), 200);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Kasir untuk\nsemua toko Anda'), findsOneWidget);
  });

  testWidgets('Firebase belum dikonfigurasi menampilkan panduan setup', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    tester.view.physicalSize = Screens.phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const AmanahKasirApp(firebaseStatus: FirebaseStatus.notConfigured),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(SetupNeededScreen), findsOneWidget);
    expect(find.text('Firebase belum disiapkan'), findsOneWidget);
    expect(find.textContaining('USE_EMULATOR'), findsOneWidget);
  });
}
