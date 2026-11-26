import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_role.dart';
import 'app_session.dart';
import 'auth_failure.dart';
import 'auth_repository.dart';
import 'store_info.dart';

/// Implementasi nyata: Firebase Auth + Firestore.
///
/// Peran dan toko dibaca dari dokumen `users/{uid}`, sumber kebenaran yang
/// sama dengan Security Rules (tanpa custom claims, jadi tidak butuh Cloud
/// Functions). Toko yang nonaktif tidak ikut sesi. Firestore menyimpan dokumen
/// di cache perangkat, jadi sesi tetap bisa dibuka saat offline setelah pernah
/// berhasil masuk; bila belum ada cache dan tidak ada koneksi, pemuatan sesi
/// gagal dan layar Login menampilkan pesannya.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Batas `whereIn` Firestore.
  static const int _whereInLimit = 30;

  @override
  Stream<SessionEvent> watchSession() =>
      _auth.idTokenChanges().asyncMap(_resolve);

  Future<SessionEvent> _resolve(User? user) async {
    if (user == null) return const SessionSignedOut();

    final snapshot = await _db.doc('users/${user.uid}').get();
    final data = snapshot.data();
    final role = AppRole.tryParse(data?['role']);
    if (data == null || role == null) {
      return const SessionRejected(SessionRejection.noRole);
    }
    // Rules juga mensyaratkan isActive == true; selain itu dianggap nonaktif.
    if (data['isActive'] != true) {
      return const SessionRejected(SessionRejection.inactiveUser);
    }

    var storeIds = const <String>[];
    if (role != AppRole.superadmin) {
      storeIds = await _activeStoreIds(_stringList(data['storeIds']));
      if (storeIds.isEmpty) {
        return const SessionRejected(SessionRejection.noActiveStore);
      }
    }
    return SessionActive(
      AppSession(
        uid: user.uid,
        email: user.email ?? '',
        name: (data['name'] as String?) ?? user.displayName ?? user.email ?? '',
        role: role,
        storeIds: storeIds,
      ),
    );
  }

  /// Toko yang benar-benar aktif (dokumen toko nonaktif tetap bisa dibaca anggotanya).
  Future<List<String>> _activeStoreIds(List<String> ids) async {
    final stores = await _fetchStores(ids);
    return [
      for (final id in ids)
        if (stores[id]?.isActive ?? false) id,
    ];
  }

  Future<Map<String, StoreInfo>> _fetchStores(List<String> ids) async {
    final result = <String, StoreInfo>{};
    for (var i = 0; i < ids.length; i += _whereInLimit) {
      final chunk = ids.sublist(i, (i + _whereInLimit).clamp(0, ids.length));
      final snapshot = await _db
          .collection('stores')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snapshot.docs) {
        result[doc.id] = StoreInfo.fromMap(doc.id, doc.data());
      }
    }
    return result;
  }

  @override
  Future<List<StoreInfo>> loadStores(List<String> storeIds) async {
    if (storeIds.isEmpty) return const [];
    final stores = await _fetchStores(storeIds);
    return [
      for (final id in storeIds)
        if (stores[id] != null) stores[id]!,
    ];
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromCode(error.code);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthFailure.fromCode(error.code);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  static List<String> _stringList(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];
}
