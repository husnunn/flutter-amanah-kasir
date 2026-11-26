import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/firebase/app_env.dart';
import 'new_user_input.dart';
import 'store_record.dart';

/// Kegagalan yang pesannya layak ditampilkan ke superadmin.
class SuperadminFailure implements Exception {
  const SuperadminFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Data yang dikelola superadmin: toko beserta penggunanya.
abstract class SuperadminRepository {
  /// Semua toko, diperbarui langsung saat dokumen toko/pengguna berubah.
  Stream<List<StoreRecord>> watchStores();

  /// Mengaktifkan/menonaktifkan toko. Anggota toko kehilangan/mendapat akses
  /// seketika karena Security Rules memeriksa `isActive` toko.
  Future<void> setStoreActive(String storeId, bool isActive);

  /// Membuat akun login (email + password) dan dokumen `users/{uid}`.
  Future<void> createUser(NewUserInput input);
}

/// Implementasi nyata: Firestore + Firebase Auth, tanpa Cloud Functions
/// (berjalan di paket Spark). Hak aksesnya dijaga firestore.rules: hanya
/// superadmin yang boleh menulis `users` dan mengubah `isActive` toko.
class FirebaseSuperadminRepository implements SuperadminRepository {
  FirebaseSuperadminRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Nama app Firebase kedua untuk membuat akun. Membuat akun lewat Auth utama
  /// akan langsung memindahkan sesi ke akun baru; app kedua menjaga sesi
  /// superadmin tetap utuh.
  static const String _secondaryAppName = 'pembuatan-pengguna';
  FirebaseAuth? _secondaryAuthCache;

  @override
  Stream<List<StoreRecord>> watchStores() {
    late final StreamController<List<StoreRecord>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? storeSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? userSub;
    Map<String, Map<String, dynamic>>? stores;
    Map<String, Map<String, dynamic>>? users;

    void emit() {
      final s = stores;
      final u = users;
      if (s == null || u == null) return;
      controller.add(buildStoreRecords(stores: s, users: u));
    }

    Map<String, Map<String, dynamic>> toMap(
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) => {for (final doc in snapshot.docs) doc.id: doc.data()};

    controller = StreamController<List<StoreRecord>>(
      onListen: () {
        storeSub = _db.collection('stores').snapshots().listen((snapshot) {
          stores = toMap(snapshot);
          emit();
        }, onError: controller.addError);
        userSub = _db.collection('users').snapshots().listen((snapshot) {
          users = toMap(snapshot);
          emit();
        }, onError: controller.addError);
      },
      onCancel: () => Future.wait([
        if (storeSub != null) storeSub!.cancel(),
        if (userSub != null) userSub!.cancel(),
      ]),
    );
    return controller.stream;
  }

  @override
  Future<void> setStoreActive(String storeId, bool isActive) async {
    try {
      await _db.doc('stores/$storeId').update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (error) {
      throw SuperadminFailure(_firestoreMessage(error));
    }
  }

  @override
  Future<void> createUser(NewUserInput input) async {
    final auth = await _secondaryAuth();
    try {
      String uid;
      try {
        final credential = await auth.createUserWithEmailAndPassword(
          email: input.cleanEmail,
          password: input.password,
        );
        uid = credential.user!.uid;
      } on FirebaseAuthException catch (error) {
        if (error.code != 'email-already-in-use') {
          throw SuperadminFailure(_authMessage(error));
        }
        uid = await _adoptUnfinishedAccount(auth, input);
      }

      try {
        await auth.currentUser?.updateDisplayName(input.cleanName);
      } on FirebaseAuthException {
        // Nama tampilan hanya pelengkap; nama utama ada di dokumen users.
      }

      try {
        await _db.doc('users/$uid').set({
          'name': input.cleanName,
          'email': input.cleanEmail,
          'role': input.role.name,
          'storeIds': input.storeIds,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (error) {
        throw SuperadminFailure(_firestoreMessage(error));
      }
    } finally {
      await auth.signOut().catchError((Object _) {});
    }
  }

  /// Akun Auth bisa sudah ada tanpa dokumen `users` bila langkah sebelumnya
  /// putus di tengah jalan (mis. koneksi hilang). Bila password yang sama
  /// dimasukkan dan dokumennya memang belum ada, akun itu dilanjutkan.
  Future<String> _adoptUnfinishedAccount(
    FirebaseAuth auth,
    NewUserInput input,
  ) async {
    const taken = SuperadminFailure('Email sudah terdaftar.');
    String uid;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: input.cleanEmail,
        password: input.password,
      );
      uid = credential.user!.uid;
    } on FirebaseAuthException {
      throw taken;
    }
    try {
      if ((await _db.doc('users/$uid').get()).exists) throw taken;
    } on FirebaseException catch (error) {
      throw SuperadminFailure(_firestoreMessage(error));
    }
    return uid;
  }

  Future<FirebaseAuth> _secondaryAuth() async {
    final cached = _secondaryAuthCache;
    if (cached != null) return cached;
    final app =
        Firebase.apps.where((a) => a.name == _secondaryAppName).firstOrNull ??
        await Firebase.initializeApp(
          name: _secondaryAppName,
          options: Firebase.app().options,
        );
    final auth = FirebaseAuth.instanceFor(app: app);
    if (AppEnv.useEmulator) {
      try {
        await auth.useAuthEmulator(
          AppEnv.emulatorHost,
          AppEnv.authEmulatorPort,
        );
      } catch (_) {
        // Sudah diarahkan ke emulator sebelumnya.
      }
    }
    return _secondaryAuthCache = auth;
  }

  static String _firestoreMessage(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' =>
        'Ditolak Security Rules. Pastikan aturan terbaru sudah di-deploy '
            '(firebase deploy --only firestore:rules).',
      'unavailable' || 'deadline-exceeded' =>
        'Tidak bisa terhubung ke server. Periksa koneksi internet.',
      'not-found' => 'Data tidak ditemukan. Mungkin sudah dihapus.',
      _ => error.message ?? 'Gagal menyimpan. Coba lagi.',
    };
  }

  static String _authMessage(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Format email tidak valid.',
      'weak-password' => 'Password terlalu lemah. Gunakan minimal 8 karakter.',
      'operation-not-allowed' =>
        'Login email/password belum diaktifkan di Firebase Console.',
      'network-request-failed' =>
        'Tidak bisa terhubung ke server. Periksa koneksi internet.',
      'too-many-requests' =>
        'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.',
      _ => 'Gagal membuat akun. Coba lagi.',
    };
  }
}
