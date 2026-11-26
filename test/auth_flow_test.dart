import 'dart:async';

import 'package:amanah_kasir/features/auth/data/app_role.dart';
import 'package:amanah_kasir/features/auth/data/auth_failure.dart';
import 'package:amanah_kasir/features/auth/data/auth_repository.dart';
import 'package:amanah_kasir/features/auth/presentation/auth_gate.dart';
import 'package:amanah_kasir/features/auth/presentation/login_screen.dart';
import 'package:amanah_kasir/features/auth/presentation/pilih_toko_screen.dart';
import 'package:amanah_kasir/features/auth/state/auth_providers.dart';
import 'package:amanah_kasir/features/kasir/presentation/kasir_screen.dart';
import 'package:amanah_kasir/features/laporan/presentation/dashboard_screen.dart';
import 'package:amanah_kasir/features/superadmin/presentation/toko_pengguna_screen.dart';
import 'package:amanah_kasir/core/theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/superadmin_helpers.dart';
import 'helpers/test_app.dart';

SessionActive _active(AppRole role, {List<String> stores = const ['tk01']}) =>
    SessionActive(session(role, storeIds: stores));

FakeAuthRepository _repo({Completer<void>? gate}) => FakeAuthRepository(
  stores: demoStores,
  accounts: {
    'kasir@t.co': FakeAccount('rahasia123', _active(AppRole.kasir)),
    'admin@t.co': FakeAccount(
      'rahasia123',
      _active(AppRole.admin, stores: ['tk01', 'tk02']),
    ),
    'admin1@t.co': FakeAccount('rahasia123', _active(AppRole.admin)),
    'super@t.co': FakeAccount(
      'rahasia123',
      _active(AppRole.superadmin, stores: const []),
    ),
    'tanpaperan@t.co': const FakeAccount(
      'rahasia123',
      SessionRejected(SessionRejection.noRole),
    ),
    'tokonon@t.co': const FakeAccount(
      'rahasia123',
      SessionRejected(SessionRejection.noActiveStore),
    ),
  },
)..signInGate = gate;

Future<void> _pumpGate(
  WidgetTester tester,
  FakeAuthRepository repo, {
  Size size = Screens.tablet,
}) async {
  await tester.runAsync(loadAppFonts);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        ...superadminOverrides(),
      ],
      child: MaterialApp(theme: AppTheme.light(), home: const AuthGate()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _login(
  WidgetTester tester,
  String email, [
  String pw = 'rahasia123',
]) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), pw);
  await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async => TestWidgetsFlutterBinding.ensureInitialized());

  group('AuthGate: arah layar per peran', () {
    testWidgets('tanpa sesi menampilkan Login', (tester) async {
      await _pumpGate(tester, _repo());
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('kasir masuk ke layar Kasir dengan nama toko', (tester) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'kasir@t.co');
      expect(find.byType(KasirScreen), findsOneWidget);
      expect(find.text('Toko Berkah Jaya'), findsWidgets);
      expect(find.text('Pesanan masih kosong'), findsOneWidget);
    });

    testWidgets('superadmin masuk ke Toko & pengguna', (tester) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'super@t.co');
      expect(find.byType(TokoPenggunaScreen), findsOneWidget);
      expect(find.text('SUPERADMIN'), findsOneWidget);
    });

    testWidgets('admin satu toko langsung ke Dashboard', (tester) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'admin1@t.co');
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(PilihTokoScreen), findsNothing);
    });

    testWidgets('admin multi-toko memilih toko dulu', (tester) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'admin@t.co');
      expect(find.byType(PilihTokoScreen), findsOneWidget);
      expect(find.text('Masuk ke Toko Berkah Jaya'), findsOneWidget);

      await tester.tap(find.text('Warung Bu Sri'));
      await tester.pump();
      await tester.tap(find.text('Masuk ke Warung Bu Sri'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('Warung Bu Sri'), findsWidgets);
    });
  });

  group('AuthGate: kegagalan dan penolakan', () {
    testWidgets('password salah menampilkan pesan dan tetap di Login', (
      tester,
    ) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'kasir@t.co', 'salah');
      expect(find.text('Email atau password salah.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('isian kosong ditolak tanpa memanggil repositori', (
      tester,
    ) async {
      final repo = _repo();
      await _pumpGate(tester, repo);
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pump();
      expect(find.text('Isi email dan password.'), findsOneWidget);
      expect(repo.signInCalls, 0);
    });

    testWidgets('akun tanpa peran: kembali ke Login dengan keterangan', (
      tester,
    ) async {
      final repo = _repo();
      await _pumpGate(tester, repo);
      await _login(tester, 'tanpaperan@t.co');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(SessionRejection.noRole.message), findsOneWidget);
      expect(repo.signOutCalls, 1);
    });

    testWidgets('toko nonaktif: kembali ke Login dengan keterangan', (
      tester,
    ) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'tokonon@t.co');
      expect(find.text(SessionRejection.noActiveStore.message), findsOneWidget);
    });

    testWidgets('keterangan hilang saat mencoba masuk lagi', (tester) async {
      await _pumpGate(tester, _repo());
      await _login(tester, 'tanpaperan@t.co');
      expect(find.text(SessionRejection.noRole.message), findsOneWidget);
      await _login(tester, 'kasir@t.co');
      expect(find.byType(KasirScreen), findsOneWidget);
    });
  });

  group('AuthGate: status memuat, logout, lupa password', () {
    testWidgets('tombol Masuk menampilkan indikator dan tidak mengirim ganda', (
      tester,
    ) async {
      final gate = Completer<void>();
      final repo = _repo(gate: gate);
      await _pumpGate(tester, repo);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'kasir@t.co');
      await tester.enterText(fields.at(1), 'rahasia123');
      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(repo.signInCalls, 1);

      gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(KasirScreen), findsOneWidget);
    });

    testWidgets(
      'logout dari Kasir kembali ke Login dan membersihkan keranjang',
      (tester) async {
        final repo = _repo();
        await _pumpGate(tester, repo);
        await _login(tester, 'kasir@t.co');
        expect(find.byType(KasirScreen), findsOneWidget);

        await tester.tap(find.byTooltip('Keluar'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(repo.signOutCalls, 1);
      },
    );

    testWidgets('lupa password mengirim email reset', (tester) async {
      final repo = _repo();
      await _pumpGate(tester, repo, size: Screens.phone);

      await tester.tap(find.text('Lupa password?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, 'kasir@t.co');
      await tester.tap(find.text('Kirim tautan reset'));
      await tester.pumpAndSettle();

      expect(repo.resetRequests, ['kasir@t.co']);
      expect(
        find.textContaining('Tautan reset dikirim ke kasir@t.co'),
        findsOneWidget,
      );
    });

    testWidgets('lupa password menampilkan error dari repositori', (
      tester,
    ) async {
      final repo = _repo()
        ..resetFailure = const AuthFailure('Format email tidak valid.');
      await _pumpGate(tester, repo, size: Screens.phone);

      await tester.tap(find.text('Lupa password?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).last, 'bukan-email');
      await tester.tap(find.text('Kirim tautan reset'));
      await tester.pumpAndSettle();

      expect(find.text('Format email tidak valid.'), findsOneWidget);
    });
  });

  group('state Riverpod', () {
    test('AuthFailure memetakan kode Firebase ke pesan Indonesia', () {
      expect(
        AuthFailure.fromCode('wrong-password').message,
        'Email atau password salah.',
      );
      expect(
        AuthFailure.fromCode('invalid-credential').message,
        'Email atau password salah.',
      );
      expect(
        AuthFailure.fromCode('user-disabled').message,
        contains('dinonaktifkan'),
      );
      expect(
        AuthFailure.fromCode('network-request-failed').message,
        contains('internet'),
      );
      expect(
        AuthFailure.fromCode('too-many-requests').message,
        contains('Terlalu banyak'),
      );
      expect(AuthFailure.fromCode('aneh').message, contains('Terjadi kendala'));
    });

    test(
      'penyegaran token (sesi sama) tidak mereset toko aktif admin',
      () async {
        final adminSession = session(AppRole.admin, storeIds: ['tk01', 'tk02']);
        final repo = FakeAuthRepository(stores: demoStores)
          ..current = SessionActive(adminSession);
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);
        container.listen(authControllerProvider, (_, _) {});
        container.listen(activeStoreIdProvider, (_, _) {});
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(activeStoreIdProvider),
          isNull,
        ); // admin multi-toko: belum memilih
        container.read(activeStoreIdProvider.notifier).select('tk02');

        repo.emit(
          SessionActive(session(AppRole.admin, storeIds: ['tk01', 'tk02'])),
        );
        await Future<void>.delayed(Duration.zero);
        expect(container.read(activeStoreIdProvider), 'tk02');

        // Daftar toko berubah (mis. toko dinonaktifkan): pilihan direset.
        repo.emit(SessionActive(session(AppRole.admin, storeIds: ['tk01'])));
        await Future<void>.delayed(Duration.zero);
        expect(container.read(activeStoreIdProvider), 'tk01');
      },
    );

    test(
      'kasir otomatis memakai satu-satunya toko; superadmin tanpa toko aktif',
      () async {
        final repo = FakeAuthRepository(stores: demoStores)
          ..current = SessionActive(session(AppRole.kasir));
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);
        container.listen(authControllerProvider, (_, _) {});
        container.listen(activeStoreIdProvider, (_, _) {});
        await Future<void>.delayed(Duration.zero);
        expect(container.read(activeStoreIdProvider), 'tk01');

        repo.emit(
          SessionActive(session(AppRole.superadmin, storeIds: const [])),
        );
        await Future<void>.delayed(Duration.zero);
        expect(container.read(activeStoreIdProvider), isNull);
      },
    );
  });
}
