import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../../core/utils/formatters.dart';

enum UserRole {
  admin('Admin'),
  kasir('Kasir');

  const UserRole(this.label);

  final String label;
}

class StoreUser {
  const StoreUser({
    required this.uid,
    required this.initials,
    required this.name,
    required this.note,
    required this.role,
    this.active = true,
  });

  final String uid;
  final String initials;
  final String name;
  final String note;
  final UserRole role;
  final bool active;
}

/// Toko di sisi superadmin: dokumen `stores/{id}` beserta pengguna yang
/// `storeIds`-nya memuat toko tersebut.
class StoreRecord {
  const StoreRecord({
    required this.id,
    required this.code,
    required this.name,
    required this.area,
    required this.users,
    this.createdLabel,
    this.active = true,
    this.scanEnabled = false,
    this.transactionsThisMonth,
  });

  /// ID dokumen (`tk01`); dipakai untuk memanggil Cloud Functions.
  final String id;
  final String code;
  final String name;

  /// Kota/daerah, diambil dari bagian terakhir alamat.
  final String area;
  final List<StoreUser> users;

  /// Tanggal dibuat, mis. "2 Nov 2026". Null bila belum tercatat di server.
  final String? createdLabel;
  final bool active;
  final bool scanEnabled;

  /// Null = belum tersedia (ringkasan harian belum dibaca dari Firestore).
  final int? transactionsThisMonth;

  /// Admin yang masih aktif di toko ini.
  List<StoreUser> get admins => [
    for (final u in users)
      if (u.role == UserRole.admin && u.active) u,
  ];

  /// Nama admin untuk kolom tabel; "—" bila belum ada.
  String get admin =>
      admins.isEmpty ? '—' : admins.map((u) => u.name).join(', ');

  int get kasirCount =>
      users.where((u) => u.role == UserRole.kasir && u.active).length;

  StoreRecord copyWith({bool? active, List<StoreUser>? users}) => StoreRecord(
    id: id,
    code: code,
    name: name,
    area: area,
    users: users ?? this.users,
    createdLabel: createdLabel,
    active: active ?? this.active,
    scanEnabled: scanEnabled,
    transactionsThisMonth: transactionsThisMonth,
  );

  StoreRecord withUser(StoreUser user) => copyWith(users: [...users, user]);
}

/// Merakit daftar toko dari isi koleksi `stores` dan `users` (id -> data).
///
/// Hasil diurutkan menurut kode toko. Pengguna tanpa peran admin/kasir
/// (mis. superadmin) tidak ikut ditampilkan.
List<StoreRecord> buildStoreRecords({
  required Map<String, Map<String, dynamic>> stores,
  required Map<String, Map<String, dynamic>> users,
}) {
  final codes = {
    for (final e in stores.entries) e.key: _codeOf(e.key, e.value),
  };

  final records = [
    for (final e in stores.entries)
      _buildStore(id: e.key, data: e.value, users: users, codes: codes),
  ]..sort((a, b) => a.code.compareTo(b.code));
  return records;
}

StoreRecord _buildStore({
  required String id,
  required Map<String, dynamic> data,
  required Map<String, Map<String, dynamic>> users,
  required Map<String, String> codes,
}) {
  final members = <StoreUser>[];
  for (final e in users.entries) {
    final storeIds = _strings(e.value['storeIds']);
    if (!storeIds.contains(id)) continue;
    final role = switch (e.value['role']) {
      'admin' => UserRole.admin,
      'kasir' => UserRole.kasir,
      _ => null,
    };
    if (role == null) continue;

    final email = (e.value['email'] as String?) ?? '';
    final name = (e.value['name'] as String?) ?? email;
    final active = e.value['isActive'] != false;
    final others = [
      for (final other in storeIds)
        if (other != id) codes[other] ?? other.toUpperCase(),
    ]..sort();
    final base = role == UserRole.admin && others.isNotEmpty
        ? 'Juga mengelola ${others.join(', ')}'
        : email;

    members.add(
      StoreUser(
        uid: e.key,
        initials: initialsOf(name),
        name: name,
        note: active ? base : 'Nonaktif · $base',
        role: role,
        active: active,
      ),
    );
  }
  members.sort((a, b) {
    if (a.role != b.role) return a.role == UserRole.admin ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  final createdAt = data['createdAt'];
  return StoreRecord(
    id: id,
    code: codes[id]!,
    name: (data['name'] as String?) ?? id,
    area: _areaOf((data['address'] as String?) ?? ''),
    users: members,
    createdLabel: createdAt is Timestamp
        ? formatDateShort(createdAt.toDate())
        : null,
    active: data['isActive'] != false,
    scanEnabled: data['scanEnabled'] == true,
  );
}

String _codeOf(String id, Map<String, dynamic> data) =>
    (data['code'] as String?) ?? id.toUpperCase();

/// "Jl. Raden Wijaya No. 20, Trowulan, Mojokerto" -> "Mojokerto".
String _areaOf(String address) {
  final parts = address
      .split(',')
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty);
  return parts.isEmpty ? '' : parts.last;
}

List<String> _strings(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];
