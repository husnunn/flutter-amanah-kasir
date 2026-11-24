import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import 'app_role.dart';

/// Sesi pengguna yang sudah lolos pemeriksaan (peran ada, user aktif, punya
/// toko aktif). [storeIds] hanya berisi toko yang aktif.
@immutable
class AppSession {
  const AppSession({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.storeIds,
  });

  final String uid;
  final String email;
  final String name;
  final AppRole role;
  final List<String> storeIds;

  String get initials => initialsOf(name);

  /// Sama dengan sesi lain bila identitas, peran, dan daftar toko sama. Dipakai
  /// agar penyegaran token berkala tidak dianggap sesi baru (dan tidak mereset
  /// toko aktif yang dipilih admin).
  @override
  bool operator ==(Object other) =>
      other is AppSession &&
      other.uid == uid &&
      other.email == email &&
      other.name == name &&
      other.role == role &&
      listEquals(other.storeIds, storeIds);

  @override
  int get hashCode =>
      Object.hash(uid, email, name, role, Object.hashAll(storeIds));
}
