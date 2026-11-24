import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_role.dart';
import 'app_session.dart';
import 'auth_failure.dart';
import 'auth_repository.dart';
import 'store_info.dart';

/// Implementasi nyata: Firebase Auth + Firestore.
///
/// Sesi dibentuk dari custom claims `role` dan `storeIds` (diset Cloud
/// Function), lalu dicocokkan dengan dokumen `users/{uid}` (isActive) dan status
/// toko. Bila Firestore tidak terjangkau (mis. offline dan belum ada cache),
/// sesi tetap dibuat dari claims agar kasir bisa bekerja.
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

    final token = await user.getIdTokenResult();
    final role = AppRole.tryParse(token.claims?['role']);
    if (role == null) return const SessionRejected(SessionRejection.noRole);
    final claimStores = _stringList(token.claims?['storeIds']);

    var name = user.displayName ?? user.email ?? '';
    var storeIds = claimStores;
    try {
      final userDoc = await _db.doc('users/${user.uid}').get();
      final data = userDoc.data();
      if (data == null) return const SessionRejected(SessionRejection.noRole);
      if (data['isActive'] == false) {
        return const SessionRejected(SessionRejection.inactiveUser);
      }
      name = (data['name'] as String?) ?? name;
      if (role != AppRole.superadmin) {
        storeIds = await _activeStoreIds(claimStores);
      }
    } on FirebaseException {
      // Firestore tidak terjangkau: pakai claims apa adanya.
    }

    if (role != AppRole.superadmin && storeIds.isEmpty) {
      return const SessionRejected(SessionRejection.noActiveStore);
    }
    return SessionActive(
      AppSession(
        uid: user.uid,
        email: user.email ?? '',
        name: name,
        role: role,
        storeIds: storeIds,
      ),
    );
  }

  /// Toko yang benar-benar aktif; token bisa tertinggal dari perubahan terbaru.
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
