import 'package:flutter/foundation.dart';

import '../../auth/data/app_role.dart';
import '../data/managed_user.dart';
import '../data/store_record.dart';

/// Pengguna yang terikat ke [storeId]: admin dulu, lalu kasir; nama berurutan.
List<ManagedUser> usersOfStore(List<ManagedUser> users, String storeId) {
  final result = [
    for (final user in users)
      if (user.storeIds.contains(storeId)) user,
  ];
  int rank(ManagedUser u) => u.role == AppRole.admin ? 0 : 1;
  result.sort((a, b) {
    final byRole = rank(a).compareTo(rank(b));
    return byRole != 0
        ? byRole
        : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return result;
}

/// Ringkasan staf aktif sebuah toko untuk baris tabel.
@immutable
class StoreStaff {
  const StoreStaff({required this.adminNames, required this.kasirCount});

  /// Nama admin aktif toko ini.
  final List<String> adminNames;
  final int kasirCount;

  /// "Sari Ayu", "Sari Ayu +1", atau "-" bila belum ada admin.
  String get adminLabel => switch (adminNames.length) {
    0 => '-',
    1 => adminNames.first,
    final n => '${adminNames.first} +${n - 1}',
  };
}

StoreStaff staffOfStore(List<ManagedUser> users, String storeId) {
  final active = usersOfStore(users, storeId).where((u) => u.isActive);
  return StoreStaff(
    adminNames: [
      for (final u in active)
        if (u.role == AppRole.admin) u.name,
    ],
    kasirCount: active.where((u) => u.role == AppRole.kasir).length,
  );
}

bool _matches(String query, Iterable<String> fields) {
  final q = query.trim().toLowerCase();
  return q.isEmpty || fields.any((f) => f.toLowerCase().contains(q));
}

/// Toko yang cocok dengan [query] (nama, kode, alamat, atau nama admin).
List<StoreRecord> filterStores(
  List<StoreRecord> stores,
  List<ManagedUser> users,
  String query,
) => [
  for (final store in stores)
    if (_matches(query, [
      store.name,
      store.code,
      store.address,
      ...staffOfStore(users, store.id).adminNames,
    ]))
      store,
];

/// Pengguna yang cocok dengan [query] (nama, email, atau kode/nama toko) dan
/// [role] (null = semua peran).
List<ManagedUser> filterUsers(
  List<ManagedUser> users,
  List<StoreRecord> stores,
  String query, {
  AppRole? role,
}) {
  final byId = {for (final s in stores) s.id: s};
  return [
    for (final user in users)
      if ((role == null || user.role == role) &&
          _matches(query, [
            user.name,
            user.email,
            for (final id in user.storeIds) ...[
              byId[id]?.code ?? '',
              byId[id]?.name ?? '',
            ],
          ]))
        user,
  ];
}

/// Angka ringkasan di atas tabel; hanya menghitung yang aktif.
@immutable
class SuperadminStats {
  const SuperadminStats({
    required this.activeStores,
    required this.totalStores,
    required this.activeAdmins,
    required this.activeKasirs,
  });

  final int activeStores;
  final int totalStores;
  final int activeAdmins;
  final int activeKasirs;
}

SuperadminStats statsOf(List<StoreRecord> stores, List<ManagedUser> users) {
  int activeWith(AppRole role) =>
      users.where((u) => u.isActive && u.role == role).length;
  return SuperadminStats(
    activeStores: stores.where((s) => s.isActive).length,
    totalStores: stores.length,
    activeAdmins: activeWith(AppRole.admin),
    activeKasirs: activeWith(AppRole.kasir),
  );
}

/// Kode toko sebuah pengguna untuk tabel: "TK01", "TK01, TK02", "TK01 +3",
/// atau "Semua toko" untuk superadmin.
String storeCodesLabel(
  ManagedUser user,
  List<StoreRecord> stores, {
  int maxShown = 2,
}) {
  if (user.role == AppRole.superadmin) return 'Semua toko';
  final byId = {for (final s in stores) s.id: s.code};
  final codes = [for (final id in user.storeIds) byId[id] ?? '?'];
  if (codes.isEmpty) return '-';
  if (codes.length <= maxShown) return codes.join(', ');
  return '${codes.take(maxShown).join(', ')} +${codes.length - maxShown}';
}
