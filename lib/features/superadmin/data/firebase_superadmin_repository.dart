import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/app_env.dart';
import '../../auth/data/app_role.dart';
import '../../auth/data/auth_failure.dart';
import 'managed_user.dart';
import 'store_record.dart';
import 'superadmin_failure.dart';
import 'superadmin_repository.dart';

/// Implementasi nyata: Firestore (baca, realtime) + Cloud Functions (tulis).
///
/// Toko dan pengguna TIDAK ditulis langsung ke Firestore: Security Rules
/// melarangnya karena kode toko harus unik dan perubahan akses harus ikut
/// memperbarui custom claims. Semua tulis lewat `upsertStore`, `setStoreActive`,
/// `upsertUser`, dan `setUserActive`.
class FirebaseSuperadminRepository implements SuperadminRepository {
  FirebaseSuperadminRepository({
    FirebaseFirestore? db,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  }) : _db = db ?? FirebaseFirestore.instance,
       _functions =
           functions ??
           FirebaseFunctions.instanceFor(region: AppEnv.functionsRegion),
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  @override
  Stream<List<StoreRecord>> watchStores() => _db
      .collection('stores')
      .snapshots()
      .map((snapshot) {
        final stores = [
          for (final doc in snapshot.docs) _storeFrom(doc.id, doc.data()),
        ]..sort((a, b) => a.code.compareTo(b.code));
        return stores;
      })
      .handleError(_rethrowStreamError);

  @override
  Stream<List<ManagedUser>> watchUsers() => _db
      .collection('users')
      .snapshots()
      .map((snapshot) {
        final users = [
          for (final doc in snapshot.docs) ?_userFrom(doc.id, doc.data()),
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return users;
      })
      .handleError(_rethrowStreamError);

  @override
  Future<int> monthlyTransactions(String storeId) => _guard(() async {
    // ID dokumen ringkasan harian = yyyy-MM-dd, jadi satu bulan = satu rentang ID.
    final now = DateTime.now();
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final snapshot = await _db
        .collection('stores/$storeId/daily_summaries')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$month-01')
        .where(FieldPath.documentId, isLessThanOrEqualTo: '$month-31')
        .get();
    return snapshot.docs.fold<int>(
      0,
      (total, doc) => total + ((doc.data()['txCount'] as num?)?.toInt() ?? 0),
    );
  });

  @override
  Future<String> saveStore(StoreDraft draft) => _guard(() async {
    final result = await _call('upsertStore', {
      'storeId': ?draft.id,
      'code': draft.code.trim().toUpperCase(),
      'name': draft.name.trim(),
      'address': draft.address.trim(),
      'phone': draft.phone.trim(),
      'scanEnabled': draft.scanEnabled,
    });
    return result['storeId'] as String;
  });

  @override
  Future<void> setStoreActive(String storeId, {required bool isActive}) =>
      _guard(
        () =>
            _call('setStoreActive', {'storeId': storeId, 'isActive': isActive}),
      );

  @override
  Future<String> saveUser(UserDraft draft) => _guard(() async {
    final result = await _call('upsertUser', {
      'uid': ?draft.uid,
      'name': draft.name.trim(),
      'email': draft.email.trim(),
      'role': draft.role.name,
      'storeIds': draft.storeIds,
      'password': ?draft.password,
    });
    return result['uid'] as String;
  });

  @override
  Future<void> setUserActive(String uid, {required bool isActive}) =>
      _guard(() => _call('setUserActive', {'uid': uid, 'isActive': isActive}));

  @override
  Future<void> sendPasswordReset(String email) => _guard(() async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw SuperadminFailure(AuthFailure.fromCode(error.code).message);
    }
  });

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, dynamic> payload,
  ) async {
    final response = await _functions.httpsCallable(name).call(payload);
    final data = response.data;
    return data is Map ? Map<String, dynamic>.from(data) : const {};
  }

  /// Mengubah kegagalan Firebase menjadi `SuperadminFailure`.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SuperadminFailure {
      rethrow;
    } on FirebaseFunctionsException catch (error) {
      throw SuperadminFailure.fromCode(error.code, error.message);
    } on FirebaseException catch (error) {
      throw SuperadminFailure.fromCode(error.code, error.message);
    } catch (_) {
      throw SuperadminFailure.fromCode('unknown');
    }
  }

  static void _rethrowStreamError(Object error, StackTrace stackTrace) {
    if (error is FirebaseException) {
      throw SuperadminFailure.fromCode(error.code, error.message);
    }
    throw SuperadminFailure.fromCode('unknown');
  }

  static StoreRecord _storeFrom(String id, Map<String, dynamic> data) =>
      StoreRecord(
        id: id,
        code: (data['code'] as String?) ?? '',
        name: (data['name'] as String?) ?? '',
        address: (data['address'] as String?) ?? '',
        phone: (data['phone'] as String?) ?? '',
        isActive: data['isActive'] != false,
        scanEnabled: data['scanEnabled'] == true,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      );

  /// Null bila peran tidak dikenal (dokumen rusak); baris itu dilewati.
  static ManagedUser? _userFrom(String uid, Map<String, dynamic> data) {
    final role = AppRole.tryParse(data['role']);
    if (role == null) return null;
    final storeIds = data['storeIds'];
    return ManagedUser(
      uid: uid,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      role: role,
      storeIds: storeIds is List ? storeIds.whereType<String>().toList() : [],
      isActive: data['isActive'] != false,
    );
  }
}
