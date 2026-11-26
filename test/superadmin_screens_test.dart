import 'dart:async';

import 'package:amanah_kasir/core/widgets/widgets.dart';
import 'package:amanah_kasir/features/superadmin/data/managed_user.dart';
import 'package:amanah_kasir/features/superadmin/data/sample_superadmin_data.dart';
import 'package:amanah_kasir/features/superadmin/data/sample_superadmin_repository.dart';
import 'package:amanah_kasir/features/superadmin/data/store_record.dart';
import 'package:amanah_kasir/features/superadmin/data/superadmin_failure.dart';
import 'package:amanah_kasir/features/superadmin/data/superadmin_repository.dart';
import 'package:amanah_kasir/features/superadmin/presentation/toko_pengguna_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/superadmin_helpers.dart';
import 'helpers/test_app.dart';

Future<void> pumpSuperadmin(
  WidgetTester tester,
  SuperadminRepository repo, {
  Size size = Screens.tablet,
  double textScale = 1,
  bool settleFirst = true,
}) async {
  await tester.runAsync(loadAppFonts);
  await pumpApp(
    tester,
    const TokoPenggunaScreen(currentUid: sampleOwnerUid),
    size: size,
    textScale: textScale,
    overrides: superadminOverrides(repo),
  );
  // Indikator memuat berputar terus, jadi pumpAndSettle tidak akan selesai.
  if (settleFirst) await tester.pumpAndSettle();
}

Finder inDialog(Finder finder) =>
    find.descendant(of: find.byType(Dialog), matching: finder);

Finder dialogFields() => inDialog(find.byType(TextFormField));

Future<void> settle(WidgetTester tester) => tester.pumpAndSettle();

Future<void> openUsers(WidgetTester tester) async {
  await tester.tap(find.text('Pengguna'));
  await settle(tester);
}

void main() {
  group('Toko', () {
    testWidgets('menampilkan ringkasan, tabel, dan panel toko pertama', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      expect(find.text('7 dari 8'), findsOneWidget); // toko aktif
      expect(find.text('Toko Sumber Rejeki'), findsOneWidget);
      // Panel menampilkan toko pertama (TK01) beserta penggunanya.
      expect(find.text('Toko Berkah Jaya'), findsNWidgets(2));
      expect(find.text('Sari Ayu'), findsWidgets);
      expect(find.text('1.284'), findsOneWidget);
    });

    testWidgets('memilih toko lain memperbarui panel', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.tap(find.text('Warung Bu Sri'));
      await settle(tester);
      expect(find.text('Warung Bu Sri'), findsNWidgets(2));
      expect(find.text('Sri Rahayu'), findsOneWidget);
      expect(find.text('412'), findsOneWidget);
    });

    testWidgets('pencarian menyaring toko berdasarkan nama admin', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.enterText(find.byType(TextFormField).first, 'hendra');
      await settle(tester);
      expect(find.text('Toko Sumber Rejeki'), findsOneWidget);
      expect(find.text('Warung Kopi Pojok'), findsOneWidget);
      expect(find.text('Warung Bu Sri'), findsNothing);

      await tester.enterText(find.byType(TextFormField).first, 'zzz');
      await settle(tester);
      expect(find.text('Toko tidak ditemukan'), findsOneWidget);
    });

    testWidgets('tambah toko: kode disarankan, toko baru terpilih', (
      tester,
    ) async {
      final repo = SampleSuperadminRepository();
      await pumpSuperadmin(tester, repo);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko'));
      await settle(tester);
      expect(inDialog(find.text('Tambah toko')), findsOneWidget);
      expect(
        tester.widget<TextFormField>(dialogFields().at(0)).controller?.text,
        'TK09',
      );

      await tester.enterText(dialogFields().at(1), 'Toko Uji Baru');
      await tester.enterText(dialogFields().at(2), 'Jl. Uji 1');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Toko Uji Baru'), findsNWidgets(2)); // tabel + panel
      expect(find.text('8 dari 9'), findsOneWidget);
      final stores = await repo.watchStores().first;
      expect(stores.any((s) => s.code == 'TK09' && s.isActive), isTrue);
    });

    testWidgets('validasi form: nama kosong ditolak, dialog tetap terbuka', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko'));
      await settle(tester);
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Nama toko 2-60 karakter.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('kode ganda tampil sebagai error di bawah field kode', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko'));
      await settle(tester);
      await tester.enterText(dialogFields().at(0), 'tk01');
      await tester.enterText(dialogFields().at(1), 'Toko Lain');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Kode toko TK01 sudah dipakai.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('edit toko: kode terkunci, nama berubah', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.tap(find.text('Edit data toko'));
      await settle(tester);
      expect(inDialog(find.text('Edit data toko')), findsOneWidget);
      final codeInput = tester.widget<EditableText>(
        find.descendant(
          of: dialogFields().at(0),
          matching: find.byType(EditableText),
        ),
      );
      expect(codeInput.readOnly, isTrue);

      await tester.enterText(dialogFields().at(1), 'Toko Berkah Sentosa');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Toko Berkah Sentosa'), findsNWidgets(2));
      expect(find.text('TK01'), findsWidgets);
    });

    testWidgets('nonaktifkan toko perlu konfirmasi; batal tidak mengubah', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.tap(find.byType(Switch));
      await settle(tester);
      expect(find.text('Nonaktifkan Toko Berkah Jaya?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await settle(tester);
      expect(find.text('7 dari 8'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await settle(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Nonaktifkan'));
      await settle(tester);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('6 dari 8'), findsOneWidget);
      expect(find.text('Nonaktif'), findsWidgets);
    });

    testWidgets('mengaktifkan toko nonaktif tanpa konfirmasi', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());

      await tester.tap(find.text('Toko Kelontong Ijo'));
      await settle(tester);
      await tester.tap(find.byType(Switch));
      await settle(tester);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('8 dari 8'), findsOneWidget);
    });

    testWidgets(
      'tambah pengguna dari panel toko: toko terisi, password sekali',
      (tester) async {
        String? clipboard;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboard = (call.arguments as Map)['text'] as String?;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        final repo = SampleSuperadminRepository();
        await pumpSuperadmin(tester, repo);

        await tester.tap(find.text('Tambah pengguna'));
        await settle(tester);
        expect(inDialog(find.text('Tambah pengguna')), findsOneWidget);
        // Toko dari panel terisi.
        expect(inDialog(find.text('TK01 - Toko Berkah Jaya')), findsOneWidget);

        await tester.enterText(dialogFields().at(0), 'Wulan Sari');
        await tester.enterText(dialogFields().at(1), 'wulan@amanah.test');
        await tester.tap(find.text('Simpan'));
        await settle(tester);

        // Password tampil sekali, 12 karakter.
        expect(find.text('Pengguna dibuat'), findsOneWidget);
        final shown = tester
            .widget<SelectableText>(find.byType(SelectableText))
            .data!;
        expect(shown.length, 12);

        await tester.tap(find.text('Salin password'));
        await settle(tester);
        expect(clipboard, shown);
        expect(find.text('Tersalin'), findsOneWidget);

        await tester.tap(find.text('Selesai'));
        await settle(tester);
        expect(find.byType(Dialog), findsNothing);
        expect(find.text('Wulan Sari'), findsOneWidget); // di panel toko
        expect(find.text(shown), findsNothing); // tidak tampil lagi
        final users = await repo.watchUsers().first;
        expect(users.any((u) => u.email == 'wulan@amanah.test'), isTrue);
      },
    );
  });

  group('Pengguna', () {
    testWidgets('tabel pengguna dengan tanda "Anda" dan kode toko', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      expect(find.text('Anda'), findsOneWidget);
      expect(find.text('Semua toko'), findsWidgets);
      expect(
        find.text('TK01, TK02'),
        findsNothing,
      ); // admin Sari: TK01, TK02 +1
      expect(find.text('TK01, TK02 +1'), findsOneWidget);
      expect(find.text('Pengguna aktif'), findsOneWidget);
    });

    testWidgets('filter peran dan pencarian', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedTabs),
          matching: find.text('Admin'),
        ),
      );
      await settle(tester);
      expect(find.text('Hendra'), findsWidgets);
      expect(find.text('Rina Wati'), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedTabs),
          matching: find.text('Semua'),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, 'tk04');
      await settle(tester);
      expect(find.text('Lilis'), findsWidgets);
      expect(find.text('Yoga'), findsWidgets);
      expect(find.text('Rina Wati'), findsNothing);
    });

    testWidgets('edit pengguna mengubah nama', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      await tester.tap(find.text('Rina Wati'));
      await settle(tester);
      await tester.tap(find.text('Edit pengguna'));
      await settle(tester);
      await tester.enterText(dialogFields().at(0), 'Rina Wati Putri');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Rina Wati Putri'), findsWidgets);
    });

    testWidgets('akun sendiri tidak bisa dinonaktifkan', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      await tester.tap(find.text('Pemilik Aplikasi'));
      await settle(tester);
      expect(find.text('Nonaktifkan pengguna'), findsNothing);
      expect(
        find.text('Akun Anda sendiri tidak bisa dinonaktifkan.'),
        findsOneWidget,
      );
    });

    testWidgets('nonaktifkan pengguna: konfirmasi lalu status berubah', (
      tester,
    ) async {
      final repo = SampleSuperadminRepository();
      await pumpSuperadmin(tester, repo);
      await openUsers(tester);

      await tester.tap(find.text('Rina Wati'));
      await settle(tester);
      await tester.tap(find.text('Nonaktifkan pengguna'));
      await settle(tester);
      expect(find.text('Nonaktifkan Rina Wati?'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Nonaktifkan'));
      await settle(tester);

      expect(find.text('Aktifkan pengguna'), findsOneWidget);
      final users = await repo.watchUsers().first;
      expect(users.singleWhere((u) => u.uid == 'u-rina').isActive, isFalse);
    });

    testWidgets('kirim tautan reset password', (tester) async {
      final repo = SampleSuperadminRepository();
      await pumpSuperadmin(tester, repo);
      await openUsers(tester);

      await tester.tap(find.text('Rina Wati'));
      await settle(tester);
      await tester.tap(find.text('Kirim tautan reset password'));
      await settle(tester);

      expect(repo.resetRequests, ['rina.wati@amanah.test']);
      expect(
        find.text('Tautan reset dikirim ke rina.wati@amanah.test.'),
        findsOneWidget,
      );
    });

    testWidgets('form pengguna mengikuti aturan toko per peran', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah pengguna'));
      await settle(tester);
      // Kasir (default): dropdown satu toko.
      expect(inDialog(find.byType(DropdownButtonFormField<String?>)), findsOne);

      await tester.tap(inDialog(find.text('Admin')));
      await settle(tester);
      expect(inDialog(find.byType(CheckboxListTile)), findsNWidgets(7));

      await tester.tap(inDialog(find.text('Superadmin')));
      await settle(tester);
      expect(
        inDialog(find.text('Superadmin mengelola semua toko.')),
        findsOneWidget,
      );
    });

    testWidgets('admin tanpa toko dan email salah ditolak di form', (
      tester,
    ) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah pengguna'));
      await settle(tester);
      await tester.tap(inDialog(find.text('Admin')));
      await settle(tester);
      await tester.enterText(dialogFields().at(0), 'Admin Baru');
      await tester.enterText(dialogFields().at(1), 'bukan-email');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Email tidak valid.'), findsOneWidget);
      expect(find.text('Pilih 1 sampai 30 toko.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('email ganda tampil di bawah field email', (tester) async {
      await pumpSuperadmin(tester, SampleSuperadminRepository());
      await openUsers(tester);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah pengguna'));
      await settle(tester);
      await tester.tap(inDialog(find.text('Superadmin'))); // tanpa toko
      await settle(tester);
      await tester.enterText(dialogFields().at(0), 'Orang Baru');
      await tester.enterText(dialogFields().at(1), 'sari.ayu@amanah.test');
      await tester.tap(find.text('Simpan'));
      await settle(tester);

      expect(find.text('Email sudah terdaftar.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('Keadaan khusus', () {
    testWidgets('kegagalan server tampil sebagai banner lalu bisa diulang', (
      tester,
    ) async {
      final repo = SampleSuperadminRepository();
      await pumpSuperadmin(tester, repo);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko'));
      await settle(tester);
      await tester.enterText(dialogFields().at(1), 'Toko Uji');
      repo.failNext = const SuperadminFailure(
        'Tidak ada koneksi internet. Coba lagi.',
        code: 'unavailable',
      );
      await tester.tap(find.text('Simpan'));
      await settle(tester);
      expect(
        find.text('Tidak ada koneksi internet. Coba lagi.'),
        findsOneWidget,
      );
      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.text('Simpan'));
      await settle(tester);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Toko Uji'), findsWidgets);
    });

    testWidgets('saat menyimpan: tombol memuat, Batal nonaktif', (
      tester,
    ) async {
      final repo = SampleSuperadminRepository()..gate = Completer<void>();
      await pumpSuperadmin(tester, repo);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko'));
      await settle(tester);
      await tester.enterText(dialogFields().at(1), 'Toko Uji');
      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(inDialog(find.byType(CircularProgressIndicator)), findsOneWidget);
      final cancel = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Batal'),
      );
      expect(cancel.onPressed, isNull);

      repo.gate!.complete();
      await settle(tester);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('belum ada toko: tampilan kosong dengan aksi tambah', (
      tester,
    ) async {
      await pumpSuperadmin(
        tester,
        SampleSuperadminRepository(stores: [], users: []),
      );
      expect(find.text('Belum ada toko'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko').last);
      await settle(tester);
      expect(inDialog(find.text('Tambah toko')), findsOneWidget);
    });

    testWidgets('memuat: indikator tampil sampai data datang', (tester) async {
      final repo = _ManualRepository();
      await pumpSuperadmin(tester, repo, settleFirst: false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repo.stores.add(const [
        StoreRecord(id: 'a', code: 'TK01', name: 'Toko A'),
      ]);
      repo.users.add(const <ManagedUser>[]);
      await tester.pumpAndSettle();
      expect(find.text('Toko A'), findsWidgets);
    });

    testWidgets('gagal memuat: pesan dan Coba lagi', (tester) async {
      final repo = _ManualRepository();
      await pumpSuperadmin(tester, repo, settleFirst: false);
      repo.stores.addError(const SuperadminFailure('Tidak berhak.'));
      await tester.pumpAndSettle();

      expect(find.text('Data belum bisa dimuat'), findsOneWidget);
      expect(find.text('Tidak berhak.'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
    });

    testWidgets('layar HP menampilkan petunjuk tablet', (tester) async {
      await pumpSuperadmin(
        tester,
        SampleSuperadminRepository(),
        size: Screens.phone,
      );
      expect(find.text('Dirancang untuk tablet'), findsOneWidget);
    });

    testWidgets('ponsel landscape (914x412): halaman digulir tanpa overflow', (
      tester,
    ) async {
      await pumpSuperadmin(
        tester,
        SampleSuperadminRepository(),
        size: const Size(914, 412),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsWidgets);

      await openUsers(tester);
      expect(tester.takeException(), isNull);

      await tester.tap(find.widgetWithText(AppButton, 'Tambah pengguna'));
      await settle(tester);
      expect(find.byType(Dialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('font 1,3x di tablet kecil: dialog tanpa overflow', (
      tester,
    ) async {
      await pumpSuperadmin(
        tester,
        SampleSuperadminRepository(),
        size: Screens.tabletSmall,
        textScale: 1.3,
      );
      await tester.tap(find.widgetWithText(AppButton, 'Tambah toko'));
      await settle(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Batal'));
      await settle(tester);

      await openUsers(tester);
      await tester.tap(find.widgetWithText(AppButton, 'Tambah pengguna'));
      await settle(tester);
      await tester.tap(inDialog(find.text('Admin')));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Repositori yang aliran datanya dikendalikan tes (untuk memuat/gagal).
class _ManualRepository extends SampleSuperadminRepository {
  final stores = StreamController<List<StoreRecord>>();
  final users = StreamController<List<ManagedUser>>();

  @override
  Stream<List<StoreRecord>> watchStores() => stores.stream;

  @override
  Stream<List<ManagedUser>> watchUsers() => users.stream;
}
