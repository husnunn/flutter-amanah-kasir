import 'dart:async';

import 'package:amanah_kasir/dev/gallery_toko_pengguna.dart';
import 'package:amanah_kasir/features/superadmin/data/new_user_input.dart';
import 'package:amanah_kasir/features/superadmin/data/store_record.dart';
import 'package:amanah_kasir/features/superadmin/data/superadmin_repository.dart';
import 'package:amanah_kasir/features/superadmin/presentation/toko_pengguna_page.dart';
import 'package:amanah_kasir/features/superadmin/state/superadmin_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/fake_superadmin_repository.dart';
import 'helpers/test_app.dart';

const _admin = StoreUser(
  uid: 'u1',
  initials: 'NI',
  name: "Ni'ammm",
  note: 'niam@contoh.com',
  role: UserRole.admin,
);

const _kasir = StoreUser(
  uid: 'u2',
  initials: 'RW',
  name: 'Rina Wati',
  note: 'rina@contoh.com',
  role: UserRole.kasir,
);

const _tk01 = StoreRecord(
  id: 'tk01',
  code: 'TK01',
  name: 'Warung Gado Gado Mbak Atik',
  area: 'Mojokerto',
  createdLabel: '2 Nov 2026',
  users: [_admin, _kasir],
);

const _tk02 = StoreRecord(
  id: 'tk02',
  code: 'TK02',
  name: 'Kios Berkah',
  area: 'Sidoarjo',
  active: false,
  users: [],
);

Future<void> _pumpPage(
  WidgetTester tester,
  FakeSuperadminRepository repo,
) async {
  await tester.runAsync(loadAppFonts);
  await pumpApp(
    tester,
    ProviderScope(
      overrides: [superadminRepositoryProvider.overrideWithValue(repo)],
      child: const TokoPenggunaPage(),
    ),
    size: Screens.tablet,
  );
  await tester.pump();
}

void main() {
  setUpAll(() async => TestWidgetsFlutterBinding.ensureInitialized());

  group('buildStoreRecords', () {
    final stores = <String, Map<String, dynamic>>{
      'tk02': {
        'code': 'TK02',
        'name': 'Kios Berkah',
        'address': 'Jl. Mawar 3, Sidoarjo',
        'isActive': false,
      },
      'tk01': {
        'code': 'TK01',
        'name': 'Warung Gado Gado Mbak Atik',
        'address': 'Jl. Raden Wijaya No. 20, Trowulan, Mojokerto',
        'isActive': true,
        'scanEnabled': true,
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 2, 10)),
      },
    };
    final users = <String, Map<String, dynamic>>{
      'u1': {
        'name': "Ni'ammm",
        'email': 'niam@contoh.com',
        'role': 'admin',
        'storeIds': ['tk01', 'tk02'],
        'isActive': true,
      },
      'u2': {
        'name': 'Rina Wati',
        'email': 'rina@contoh.com',
        'role': 'kasir',
        'storeIds': ['tk01'],
      },
      'u3': {
        'name': 'Budi',
        'email': 'budi@contoh.com',
        'role': 'kasir',
        'storeIds': ['tk01'],
        'isActive': false,
      },
      'su': {
        'name': 'Pemilik',
        'email': 'pemilik@contoh.com',
        'role': 'superadmin',
        'storeIds': <String>[],
      },
    };

    test('mengurutkan menurut kode dan membaca info toko', () {
      final records = buildStoreRecords(stores: stores, users: users);
      expect(records.map((r) => r.code), ['TK01', 'TK02']);

      final tk01 = records.first;
      expect(tk01.id, 'tk01');
      expect(tk01.name, 'Warung Gado Gado Mbak Atik');
      expect(tk01.area, 'Mojokerto');
      expect(tk01.createdLabel, '2 Nov 2026');
      expect(tk01.active, isTrue);
      expect(tk01.scanEnabled, isTrue);
      expect(tk01.transactionsThisMonth, isNull);

      final tk02 = records.last;
      expect(tk02.area, 'Sidoarjo');
      expect(tk02.createdLabel, isNull);
      expect(tk02.active, isFalse);
      expect(tk02.scanEnabled, isFalse);
    });

    test('pengguna: admin dulu, nonaktif ditandai, superadmin tidak ikut', () {
      final tk01 = buildStoreRecords(stores: stores, users: users).first;

      expect(tk01.users.map((u) => u.name), ["Ni'ammm", 'Budi', 'Rina Wati']);
      expect(tk01.users.map((u) => u.uid), ['u1', 'u3', 'u2']);
      expect(tk01.users[0].note, 'Juga mengelola TK02');
      expect(tk01.users[1].note, 'Nonaktif · budi@contoh.com');
      expect(tk01.users[2].note, 'rina@contoh.com');
      expect(tk01.users[2].initials, 'RW');
    });

    test('hitungan admin dan kasir hanya memuat akun aktif', () {
      final records = buildStoreRecords(stores: stores, users: users);
      expect(records.first.admin, "Ni'ammm");
      expect(records.first.kasirCount, 1); // Budi nonaktif
      expect(records.last.admin, "Ni'ammm");
      expect(records.last.kasirCount, 0);
      expect(records.last.users.single.note, 'Juga mengelola TK01');
    });

    test('toko tanpa admin menampilkan tanda strip', () {
      final records = buildStoreRecords(
        stores: {'tk09': <String, dynamic>{}},
        users: const {},
      );
      expect(records.single.admin, '—');
      expect(records.single.code, 'TK09');
      expect(records.single.name, 'tk09');
      expect(records.single.area, '');
      expect(records.single.active, isTrue);
    });
  });

  group('Toko & pengguna terhubung ke repositori', () {
    testWidgets('memuat lalu menampilkan toko dan penggunanya', (tester) async {
      final repo = FakeSuperadminRepository();
      await _pumpPage(tester, repo);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Warung Gado Gado Mbak Atik'), findsNothing);

      repo.emit([_tk01, _tk02]);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Tabel + panel detail (toko pertama terpilih otomatis).
      expect(find.text('Warung Gado Gado Mbak Atik'), findsWidgets);
      expect(find.text('Kios Berkah'), findsOneWidget);
      expect(find.text('1 dari 2'), findsOneWidget);
      expect(find.text('Rina Wati'), findsOneWidget);
      expect(find.text('rina@contoh.com'), findsOneWidget);
      expect(find.text('Berkah Jaya'), findsNothing); // bukan data contoh
    });

    testWidgets('daftar kosong menampilkan pesan', (tester) async {
      final repo = FakeSuperadminRepository(initial: const []);
      await _pumpPage(tester, repo);

      expect(find.text('Belum ada toko'), findsOneWidget);
    });

    testWidgets('gagal memuat: Coba lagi mengambil ulang', (tester) async {
      final repo = FakeSuperadminRepository(initial: [_tk01])
        ..watchError = Exception('permission-denied');
      await _pumpPage(tester, repo);

      expect(find.text('Tidak bisa memuat toko'), findsOneWidget);
      expect(repo.watchCalls, 1);

      repo.watchError = null;
      await tester.tap(find.text('Coba lagi'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Tidak bisa memuat toko'), findsNothing);
      expect(find.text('Warung Gado Gado Mbak Atik'), findsWidgets);
      expect(repo.watchCalls, 2);
    });

    testWidgets('sakelar memanggil repositori dan hitungan mengikuti', (
      tester,
    ) async {
      final repo = FakeSuperadminRepository(initial: [_tk01, _tk02]);
      await _pumpPage(tester, repo);

      expect(find.text('1 dari 2'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();

      expect(repo.toggles, [('tk01', false)]);
      expect(find.text('0 dari 2'), findsOneWidget);
    });

    testWidgets('sakelar terkunci selama perubahan berjalan', (tester) async {
      final gate = Completer<void>();
      final repo = FakeSuperadminRepository(initial: [_tk01])
        ..toggleGate = gate;
      await _pumpPage(tester, repo);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);

      gate.complete();
      await tester.pump();
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNotNull);
      expect(repo.toggles, hasLength(1));
    });

    testWidgets('perubahan gagal menampilkan pesan dan status tetap', (
      tester,
    ) async {
      final repo = FakeSuperadminRepository(initial: [_tk01, _tk02])
        ..toggleFailure = const SuperadminFailure(
          'Cloud Functions belum di-deploy.',
        );
      await _pumpPage(tester, repo);

      await tester.tap(find.byType(Switch));
      await tester.pump();
      await tester.pump();

      expect(find.text('Cloud Functions belum di-deploy.'), findsOneWidget);
      expect(find.text('1 dari 2'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNotNull);
    });
  });

  group('NewUserInput.validate', () {
    NewUserInput input({
      String name = 'Rina',
      String email = 'rina@contoh.com',
      String password = 'rahasia123',
      UserRole role = UserRole.kasir,
      List<String> storeIds = const ['tk01'],
    }) => NewUserInput(
      name: name,
      email: email,
      password: password,
      role: role,
      storeIds: storeIds,
    );

    test('isian sah lolos dan email dirapikan', () {
      final ok = input(name: '  Rina ', email: ' Rina@Contoh.COM ');
      expect(ok.validate(), isNull);
      expect(ok.cleanName, 'Rina');
      expect(ok.cleanEmail, 'rina@contoh.com');
    });

    test('nama, email, dan password diperiksa', () {
      expect(input(name: '  ').validate(), 'Nama wajib diisi.');
      expect(input(email: 'bukan-email').validate(), 'Email tidak valid.');
      expect(input(email: 'a@b').validate(), 'Email tidak valid.');
      expect(
        input(password: '1234567').validate(),
        'Password minimal 8 karakter.',
      );
      expect(input(password: '12345678').validate(), isNull);
    });

    test('kasir tepat satu toko, admin minimal satu', () {
      expect(
        input(storeIds: const []).validate(),
        'Kasir harus terikat ke tepat satu toko.',
      );
      expect(
        input(storeIds: const ['tk01', 'tk02']).validate(),
        'Kasir harus terikat ke tepat satu toko.',
      );
      expect(
        input(role: UserRole.admin, storeIds: const []).validate(),
        'Admin harus mengelola minimal satu toko.',
      );
      expect(
        input(
          role: UserRole.admin,
          storeIds: const ['tk01', 'tk02'],
        ).validate(),
        isNull,
      );
    });
  });

  group('Tambah pengguna', () {
    final dialogFields = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextFormField),
    );

    Future<FakeSuperadminRepository> openDialog(WidgetTester tester) async {
      final repo = FakeSuperadminRepository(initial: [_tk01, _tk02]);
      await _pumpPage(tester, repo);
      await tester.tap(find.text('Tambah pengguna'));
      await tester.pumpAndSettle();
      return repo;
    }

    Future<void> fill(WidgetTester tester) async {
      await tester.enterText(dialogFields.at(0), 'Rina Baru');
      await tester.enterText(dialogFields.at(1), ' Rina@Contoh.com ');
      await tester.enterText(dialogFields.at(2), 'rahasia123');
    }

    bool checked(WidgetTester tester, String id) => tester
        .widget<CheckboxListTile>(find.byKey(ValueKey('toko-$id')))
        .value!;

    testWidgets('membuka formulir dengan toko terpilih sudah dicentang', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.byType(Dialog), findsOneWidget);
      expect(checked(tester, 'tk01'), isTrue);
      expect(checked(tester, 'tk02'), isFalse);
    });

    testWidgets('isian kosong menampilkan pesan dan tidak menyimpan', (
      tester,
    ) async {
      final repo = await openDialog(tester);

      await tester.tap(find.text('Simpan'));
      await tester.pump();

      expect(find.text('Nama wajib diisi.'), findsOneWidget);
      expect(repo.created, isEmpty);
    });

    testWidgets('berhasil: menyimpan, menutup dialog, pengguna muncul', (
      tester,
    ) async {
      final repo = await openDialog(tester);
      await fill(tester);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(repo.created, hasLength(1));
      final saved = repo.created.single;
      expect(saved.cleanName, 'Rina Baru');
      expect(saved.cleanEmail, 'rina@contoh.com');
      expect(saved.password, 'rahasia123');
      expect(saved.role, UserRole.kasir);
      expect(saved.storeIds, ['tk01']);

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('Rina Baru ditambahkan.'), findsOneWidget);
      expect(find.text('Rina Baru'), findsOneWidget); // di panel pengguna
      expect(find.text('3 orang'), findsOneWidget);
    });

    testWidgets('gagal: pesan tampil dan dialog tetap terbuka', (tester) async {
      final repo = await openDialog(tester);
      repo.createFailure = const SuperadminFailure('Email sudah terdaftar.');
      await fill(tester);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Email sudah terdaftar.'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('2 orang'), findsOneWidget); // panel belum berubah

      // Isian tidak hilang; setelah diperbaiki bisa disimpan lagi.
      repo.createFailure = null;
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
      expect(repo.created, hasLength(2));
    });

    testWidgets('admin boleh beberapa toko, kasir hanya satu', (tester) async {
      await openDialog(tester);
      Finder inDialog(String label) =>
          find.descendant(of: find.byType(Dialog), matching: find.text(label));

      await tester.tap(inDialog('Admin'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('toko-tk02')));
      await tester.pump();
      expect(checked(tester, 'tk01'), isTrue);
      expect(checked(tester, 'tk02'), isTrue);

      // Kembali ke kasir: hanya toko pertama yang tersisa.
      await tester.tap(inDialog('Kasir'));
      await tester.pump();
      expect(checked(tester, 'tk01'), isTrue);
      expect(checked(tester, 'tk02'), isFalse);

      // Memilih toko lain menggantikan, bukan menambah.
      await tester.tap(find.byKey(const ValueKey('toko-tk02')));
      await tester.pump();
      expect(checked(tester, 'tk01'), isFalse);
      expect(checked(tester, 'tk02'), isTrue);
    });

    testWidgets('batal menutup dialog tanpa menyimpan', (tester) async {
      final repo = await openDialog(tester);

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(repo.created, isEmpty);
    });

    testWidgets('di galeri (tanpa Firebase) tombol masih "segera hadir"', (
      tester,
    ) async {
      await tester.runAsync(loadAppFonts);
      await pumpApp(tester, const GalleryTokoPengguna(), size: Screens.tablet);

      await tester.tap(find.text('Tambah pengguna'));
      await tester.pump();

      expect(find.text('Tambah pengguna segera hadir'), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
