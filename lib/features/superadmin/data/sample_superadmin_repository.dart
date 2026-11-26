import 'dart:async';

import 'managed_user.dart';
import 'sample_superadmin_data.dart';
import 'store_record.dart';
import 'superadmin_failure.dart';
import 'superadmin_repository.dart';

/// Repositori di memori untuk galeri UI dan tes (tanpa Firebase).
///
/// Meniru aturan server yang penting supaya penanganan error bisa dilihat dan
/// dites: kode toko dan email tidak boleh kembar, input tidak valid ditolak.
class SampleSuperadminRepository implements SuperadminRepository {
  SampleSuperadminRepository({
    List<StoreRecord>? stores,
    List<ManagedUser>? users,
    Map<String, int>? transactions,
  }) : _stores = List.of(stores ?? sampleStores),
       _users = List.of(users ?? sampleUsers),
       _transactions = transactions ?? sampleMonthlyTransactions;

  List<StoreRecord> _stores;
  List<ManagedUser> _users;
  final Map<String, int> _transactions;

  final _storeChanges = StreamController<List<StoreRecord>>.broadcast();
  final _userChanges = StreamController<List<ManagedUser>>.broadcast();

  /// Bila diisi, aksi tulis berikutnya gagal dengan kegagalan ini (sekali saja).
  SuperadminFailure? failNext;

  /// Bila diisi, aksi tulis menunggu sampai selesai (untuk menguji status memuat).
  Completer<void>? gate;

  final List<String> resetRequests = [];
  int _nextId = 100;

  @override
  Stream<List<StoreRecord>> watchStores() async* {
    yield List.unmodifiable(_stores);
    yield* _storeChanges.stream;
  }

  @override
  Stream<List<ManagedUser>> watchUsers() async* {
    yield List.unmodifiable(_users);
    yield* _userChanges.stream;
  }

  @override
  Future<int> monthlyTransactions(String storeId) async =>
      _transactions[storeId] ?? 0;

  @override
  Future<String> saveStore(StoreDraft draft) async {
    await _beforeWrite();
    final errors = validateStoreDraft(draft);
    if (errors.isNotEmpty) throw SuperadminFailure(errors.values.first);

    final id = draft.id;
    if (id == null) {
      final code = draft.code.trim().toUpperCase();
      if (_stores.any((s) => s.code == code)) {
        throw SuperadminFailure(
          'Kode toko $code sudah dipakai.',
          code: 'already-exists',
        );
      }
      final newId = 'tk${_nextId++}';
      _stores = [
        ..._stores,
        StoreRecord(
          id: newId,
          code: code,
          name: draft.name.trim(),
          address: draft.address.trim(),
          phone: draft.phone.trim(),
          scanEnabled: draft.scanEnabled,
          createdAt: DateTime.now(),
        ),
      ]..sort((a, b) => a.code.compareTo(b.code));
      _storeChanges.add(List.unmodifiable(_stores));
      return newId;
    }

    if (!_stores.any((s) => s.id == id)) {
      throw const SuperadminFailure('Toko tidak ditemukan.');
    }
    _replaceStore(
      id,
      (s) => s.copyWith(
        name: draft.name.trim(),
        address: draft.address.trim(),
        phone: draft.phone.trim(),
        scanEnabled: draft.scanEnabled,
      ),
    );
    return id;
  }

  @override
  Future<void> setStoreActive(String storeId, {required bool isActive}) async {
    await _beforeWrite();
    _replaceStore(storeId, (s) => s.copyWith(isActive: isActive));
  }

  @override
  Future<String> saveUser(UserDraft draft) async {
    await _beforeWrite();
    final errors = validateUserDraft(draft);
    if (errors.isNotEmpty) throw SuperadminFailure(errors.values.first);

    final email = draft.email.trim().toLowerCase();
    final uid = draft.uid;
    if (_users.any((u) => u.email == email && u.uid != uid)) {
      throw const SuperadminFailure(
        'Email sudah terdaftar.',
        code: 'already-exists',
      );
    }

    if (uid == null) {
      final newUid = 'u-${_nextId++}';
      _users = [
        ..._users,
        ManagedUser(
          uid: newUid,
          name: draft.name.trim(),
          email: email,
          role: draft.role,
          storeIds: draft.storeIds,
        ),
      ];
      _publishUsers();
      return newUid;
    }

    final existing = _users.where((u) => u.uid == uid).firstOrNull;
    if (existing == null) {
      throw const SuperadminFailure('Pengguna tidak ditemukan.');
    }
    _users = [
      for (final u in _users)
        if (u.uid == uid)
          ManagedUser(
            uid: uid,
            name: draft.name.trim(),
            email: email,
            role: draft.role,
            storeIds: draft.storeIds,
            isActive: existing.isActive,
          )
        else
          u,
    ];
    _publishUsers();
    return uid;
  }

  @override
  Future<void> setUserActive(String uid, {required bool isActive}) async {
    await _beforeWrite();
    _users = [
      for (final u in _users)
        if (u.uid == uid) u.copyWith(isActive: isActive) else u,
    ];
    _publishUsers();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _beforeWrite();
    resetRequests.add(email.trim());
  }

  Future<void> _beforeWrite() async {
    final pending = gate;
    if (pending != null) await pending.future;
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
  }

  void _replaceStore(String id, StoreRecord Function(StoreRecord) change) {
    _stores = [
      for (final s in _stores)
        if (s.id == id) change(s) else s,
    ];
    _storeChanges.add(List.unmodifiable(_stores));
  }

  void _publishUsers() => _userChanges.add(List.unmodifiable(_users));
}
