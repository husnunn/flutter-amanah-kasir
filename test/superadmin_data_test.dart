import 'dart:math';

import 'package:amanah_kasir/features/auth/data/app_role.dart';
import 'package:amanah_kasir/features/superadmin/data/managed_user.dart';
import 'package:amanah_kasir/features/superadmin/data/sample_superadmin_data.dart';
import 'package:amanah_kasir/features/superadmin/data/sample_superadmin_repository.dart';
import 'package:amanah_kasir/features/superadmin/data/store_record.dart';
import 'package:amanah_kasir/features/superadmin/data/superadmin_failure.dart';
import 'package:flutter_test/flutter_test.dart';

UserDraft user({
  String? uid,
  String name = 'Rina',
  String email = 'rina@amanah.test',
  AppRole role = AppRole.kasir,
  List<String> storeIds = const ['tk01'],
  String? password = 'abcd1234',
}) => UserDraft(
  uid: uid,
  name: name,
  email: email,
  role: role,
  storeIds: storeIds,
  password: password,
);

void main() {
  group('validateStoreDraft', () {
    const valid = StoreDraft(code: 'tk09', name: 'Toko Uji');

    test('isian benar lolos (kode huruf kecil dinormalkan)', () {
      expect(validateStoreDraft(valid), isEmpty);
    });

    test('kode wajib, 2-8 huruf/angka tanpa spasi atau simbol', () {
      for (final bad in ['', 'A', 'TERLALUPANJANG', 'TK 01', 'TK-01']) {
        final errors = validateStoreDraft(StoreDraft(code: bad, name: 'Toko'));
        expect(errors.keys, contains('code'), reason: bad);
      }
    });

    test('kode tidak diperiksa saat mengubah toko (tidak bisa diubah)', () {
      const edit = StoreDraft(id: 'tk01', code: '', name: 'Toko Baru');
      expect(validateStoreDraft(edit), isEmpty);
    });

    test('nama 2-60 karakter', () {
      for (final bad in ['', ' ', 'A', 'x' * 61]) {
        final errors = validateStoreDraft(StoreDraft(code: 'TK09', name: bad));
        expect(errors.keys, contains('name'), reason: bad);
      }
    });

    test('alamat dan telepon dibatasi', () {
      final longAddress = StoreDraft(
        code: 'TK09',
        name: 'Toko',
        address: 'x' * 121,
      );
      expect(validateStoreDraft(longAddress).keys, contains('address'));
      for (final bad in ['telepon', '1' * 21]) {
        final draft = StoreDraft(code: 'TK09', name: 'Toko', phone: bad);
        expect(validateStoreDraft(draft).keys, contains('phone'), reason: bad);
      }
      const phoneOk = StoreDraft(
        code: 'TK09',
        name: 'Toko',
        phone: '+62 812-3456',
      );
      expect(validateStoreDraft(phoneOk), isEmpty);
    });
  });

  group('suggestStoreCode', () {
    StoreRecord store(String code) =>
        StoreRecord(id: code, code: code, name: code);

    test('nomor terbesar + 1, dua digit', () {
      expect(suggestStoreCode([store('TK01'), store('TK08')]), 'TK09');
    });

    test('kosong atau tanpa pola TK mulai dari TK01', () {
      expect(suggestStoreCode(const []), 'TK01');
      expect(suggestStoreCode([store('ABC')]), 'TK01');
    });

    test('lebih dari 99 tetap berurutan', () {
      expect(suggestStoreCode([store('TK99')]), 'TK100');
    });
  });

  group('validateUserDraft', () {
    test('kasir tepat satu toko', () {
      expect(validateUserDraft(user()), isEmpty);
      expect(validateUserDraft(user(storeIds: [])).keys, contains('stores'));
      expect(
        validateUserDraft(user(storeIds: ['tk01', 'tk02'])).keys,
        contains('stores'),
      );
    });

    test('admin boleh banyak toko, minimal satu, maksimal 30', () {
      final admin = user(role: AppRole.admin, storeIds: ['tk01', 'tk02']);
      expect(validateUserDraft(admin), isEmpty);
      expect(
        validateUserDraft(user(role: AppRole.admin, storeIds: [])).keys,
        contains('stores'),
      );
      final tooMany = [for (var i = 0; i < 31; i++) 's$i'];
      expect(
        validateUserDraft(user(role: AppRole.admin, storeIds: tooMany)).keys,
        contains('stores'),
      );
    });

    test('superadmin tanpa toko', () {
      expect(
        validateUserDraft(user(role: AppRole.superadmin, storeIds: [])),
        isEmpty,
      );
      expect(
        validateUserDraft(user(role: AppRole.superadmin)).keys,
        contains('stores'),
      );
    });

    test('nama dan email wajib valid', () {
      expect(validateUserDraft(user(name: '  ')).keys, contains('name'));
      for (final bad in ['', 'rina', 'rina@', 'rina@amanah', 'a b@c.id']) {
        expect(
          validateUserDraft(user(email: bad)).keys,
          contains('email'),
          reason: bad,
        );
      }
    });

    test('password wajib minimal 8 karakter hanya untuk pengguna baru', () {
      expect(
        validateUserDraft(user(password: null)).keys,
        contains('password'),
      );
      expect(
        validateUserDraft(user(password: 'pendek')).keys,
        contains('password'),
      );
      expect(validateUserDraft(user(uid: 'u1', password: null)), isEmpty);
    });
  });

  group('PasswordGenerator', () {
    test('12 karakter dengan huruf besar, kecil, angka, dan simbol', () {
      for (var i = 0; i < 200; i++) {
        final password = PasswordGenerator.generate();
        expect(password.length, 12);
        expect(password, matches(RegExp('[A-Z]')));
        expect(password, matches(RegExp('[a-z]')));
        expect(password, matches(RegExp('[0-9]')));
        expect(password, matches(RegExp(r'[@#$%&*+?]')));
      }
    });

    test('tanpa karakter yang mudah tertukar', () {
      for (var i = 0; i < 200; i++) {
        expect(PasswordGenerator.generate(), isNot(matches(RegExp('[0OIl1]'))));
      }
    });

    test('acak: tidak ada dua hasil yang sama berturut-turut', () {
      final all = {for (var i = 0; i < 100; i++) PasswordGenerator.generate()};
      expect(all.length, 100);
    });

    test('lolos validasi password server (minimal 8)', () {
      expect(PasswordGenerator.generate().length, greaterThanOrEqualTo(8));
    });

    test('deterministik bila Random diberi seed (hanya untuk tes)', () {
      expect(
        PasswordGenerator.generate(random: Random(7)),
        PasswordGenerator.generate(random: Random(7)),
      );
    });
  });

  group('SuperadminFailure.fromCode', () {
    test(
      'pesan server berbahasa Indonesia dipakai untuk kode yang dikenal',
      () {
        final failure = SuperadminFailure.fromCode(
          'already-exists',
          'Kode toko TK01 sudah dipakai.',
        );
        expect(failure.message, 'Kode toko TK01 sudah dipakai.');
      },
    );

    test('kode dibawa agar kode/email ganda bisa tampil di field', () {
      final duplicate = SuperadminFailure.fromCode('already-exists', 'Ada.');
      expect(duplicate.isDuplicate, isTrue);
      expect(SuperadminFailure.fromCode('internal').isDuplicate, isFalse);
      expect(const SuperadminFailure('Gagal.').isDuplicate, isFalse);
    });

    test('internal tidak membocorkan teks teknis', () {
      final failure = SuperadminFailure.fromCode(
        'internal',
        'TypeError: x is not a function',
      );
      expect(failure.message, 'Terjadi kendala. Coba lagi.');
    });

    test('tanpa pesan server memakai pesan bawaan', () {
      expect(
        SuperadminFailure.fromCode('permission-denied').message,
        'Anda tidak berhak melakukan ini.',
      );
      expect(
        SuperadminFailure.fromCode('unavailable').message,
        'Tidak ada koneksi internet. Coba lagi.',
      );
      expect(
        SuperadminFailure.fromCode('unauthenticated').message,
        contains('Masuk lagi'),
      );
    });
  });

  group('SampleSuperadminRepository', () {
    test('kode toko kembar ditolak tanpa peduli huruf besar/kecil', () async {
      final repo = SampleSuperadminRepository();
      await expectLater(
        repo.saveStore(const StoreDraft(code: 'tk01', name: 'Lain')),
        throwsA(
          isA<SuperadminFailure>().having(
            (e) => e.message,
            'message',
            'Kode toko TK01 sudah dipakai.',
          ),
        ),
      );
    });

    test('toko baru muncul di aliran dengan id baru', () async {
      final repo = SampleSuperadminRepository();
      final id = await repo.saveStore(
        const StoreDraft(code: 'tk09', name: 'Toko Uji', scanEnabled: true),
      );
      final stores = await repo.watchStores().first;
      final created = stores.singleWhere((s) => s.id == id);
      expect(created.code, 'TK09');
      expect(created.isActive, isTrue);
      expect(created.scanEnabled, isTrue);
    });

    test('mengubah toko tidak mengubah kodenya', () async {
      final repo = SampleSuperadminRepository();
      await repo.saveStore(
        const StoreDraft(id: 'tk01', code: 'ZZ99', name: 'Nama Baru'),
      );
      final stores = await repo.watchStores().first;
      final edited = stores.singleWhere((s) => s.id == 'tk01');
      expect(edited.name, 'Nama Baru');
      expect(edited.code, 'TK01');
    });

    test(
      'email kembar ditolak; mengubah diri sendiri dengan email sama boleh',
      () async {
        final repo = SampleSuperadminRepository();
        await expectLater(
          repo.saveUser(user(email: 'Sari.Ayu@amanah.test')),
          throwsA(isA<SuperadminFailure>()),
        );
        final uid = await repo.saveUser(
          user(uid: 'u-rina', email: 'rina.wati@amanah.test', name: 'Rina W'),
        );
        expect(uid, 'u-rina');
      },
    );

    test('failNext hanya berlaku sekali', () async {
      final repo = SampleSuperadminRepository()
        ..failNext = const SuperadminFailure('Gagal.');
      await expectLater(
        repo.setUserActive('u-rina', isActive: false),
        throwsA(isA<SuperadminFailure>()),
      );
      await repo.setUserActive('u-rina', isActive: false);
      final users = await repo.watchUsers().first;
      expect(users.singleWhere((u) => u.uid == 'u-rina').isActive, isFalse);
    });

    test(
      'nonaktifkan toko mengubah status; transaksi bulan ini dari data',
      () async {
        final repo = SampleSuperadminRepository();
        await repo.setStoreActive('tk01', isActive: false);
        final stores = await repo.watchStores().first;
        expect(stores.singleWhere((s) => s.id == 'tk01').isActive, isFalse);
        expect(await repo.monthlyTransactions('tk01'), 1284);
        expect(await repo.monthlyTransactions('tidak-ada'), 0);
        expect(sampleOwnerUid, 'u-owner');
      },
    );
  });
}
