import 'package:amanah_kasir/dev/gallery_toko_pengguna.dart';
import 'package:amanah_kasir/features/keuangan/presentation/pengeluaran_screen.dart';
import 'package:amanah_kasir/features/laporan/presentation/dashboard_screen.dart';
import 'package:amanah_kasir/features/produk/presentation/produk_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/test_app.dart';

void main() {
  setUpAll(() async => TestWidgetsFlutterBinding.ensureInitialized());

  testWidgets('edit produk: simpan memperbarui daftar', (tester) async {
    await tester.runAsync(loadAppFonts);
    await pumpApp(tester, const ProdukScreen(), size: Screens.tablet);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Telur Ayam 1 kg'),
      'Telur Omega',
    );
    await tester.tap(find.text('Simpan perubahan'));
    await tester.pump();

    expect(find.text('Telur Omega'), findsWidgets);
    expect(find.text('Telur Ayam 1 kg'), findsNothing);
  });

  testWidgets('edit produk: nonaktifkan menandai baris', (tester) async {
    await tester.runAsync(loadAppFonts);
    await pumpApp(tester, const ProdukScreen(), size: Screens.tablet);

    await tester.tap(find.text('Nonaktifkan'));
    await tester.pump();

    expect(find.textContaining('Nonaktif'), findsWidgets);
    expect(find.text('Aktifkan'), findsOneWidget);
  });

  testWidgets('filter stok menipis menyisakan produk di bawah minimum', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    await pumpApp(tester, const ProdukScreen(), size: Screens.tablet);

    await tester.tap(find.textContaining('Stok menipis'));
    await tester.pump();

    expect(find.text('Telur Ayam 1 kg'), findsWidgets);
    expect(find.text('Mi Instan Goreng'), findsNothing);
  });

  testWidgets('superadmin: sakelar toko mengubah hitungan toko aktif', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    await pumpApp(tester, const GalleryTokoPengguna(), size: Screens.tablet);

    expect(find.text('7 dari 8'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('6 dari 8'), findsOneWidget);
  });

  testWidgets('dashboard: ganti periode mengubah ringkasan', (tester) async {
    await tester.runAsync(loadAppFonts);
    await pumpApp(tester, const DashboardScreen(), size: Screens.tablet);

    expect(find.text('Rp 39.230.000'), findsOneWidget); // Bulan
    await tester.tap(find.text('Hari'));
    await tester.pump();
    expect(find.text('Rp 1.620.000'), findsWidgets);
    expect(find.text('Rp 39.230.000'), findsNothing);
  });

  testWidgets('pengeluaran: nominal kosong ditolak, terisi tersimpan', (
    tester,
  ) async {
    await tester.runAsync(loadAppFonts);
    var saved = 0;
    await pumpApp(
      tester,
      PengeluaranScreen(onSaved: (d) => saved = d.amount),
      size: Screens.phone,
    );

    await tester.tap(find.text('Simpan pengeluaran'));
    await tester.pump();
    expect(find.text('Isi nominal pengeluaran'), findsOneWidget);
    expect(saved, 0);

    await tester.enterText(find.byType(TextField).first, '150000');
    await tester.tap(find.text('Simpan pengeluaran'));
    await tester.pump();
    expect(saved, 150000);
  });
}
