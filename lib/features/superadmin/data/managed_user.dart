import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../auth/data/app_role.dart';

/// Pengguna di sisi superadmin (dokumen `users/{uid}`).
@immutable
class ManagedUser {
  const ManagedUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.storeIds = const [],
    this.isActive = true,
  });

  final String uid;
  final String name;
  final String email;
  final AppRole role;

  /// Kasir: tepat satu; admin: satu atau lebih; superadmin: kosong.
  final List<String> storeIds;
  final bool isActive;

  String get initials => initialsOf(name);

  ManagedUser copyWith({bool? isActive}) => ManagedUser(
    uid: uid,
    name: name,
    email: email,
    role: role,
    storeIds: storeIds,
    isActive: isActive ?? this.isActive,
  );
}

/// Isian form pengguna. [uid] null = pengguna baru. [password] hanya dikirim
/// untuk pengguna baru (dibuat otomatis oleh aplikasi).
@immutable
class UserDraft {
  const UserDraft({
    this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.storeIds = const [],
    this.password,
  });

  final String? uid;
  final String name;
  final String email;
  final AppRole role;
  final List<String> storeIds;
  final String? password;

  bool get isCreate => uid == null;
}

/// Batas toko per admin; sama dengan `MAX_STORES_PER_USER` di functions.
const int maxStoresPerAdmin = 30;

const int passwordMinLength = 8;

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Pesan error per field ('name', 'email', 'stores', 'password'); kosong =
/// valid. Aturannya sama dengan `validateUserInput` di `functions/src/claims.js`.
Map<String, String> validateUserDraft(UserDraft draft) {
  final errors = <String, String>{};

  if (draft.name.trim().isEmpty) errors['name'] = 'Nama wajib diisi.';
  if (!_emailPattern.hasMatch(draft.email.trim())) {
    errors['email'] = 'Email tidak valid.';
  }

  final count = draft.storeIds.length;
  switch (draft.role) {
    case AppRole.superadmin:
      if (count != 0) errors['stores'] = 'Superadmin tidak terikat ke toko.';
    case AppRole.kasir:
      if (count != 1) errors['stores'] = 'Pilih satu toko untuk kasir.';
    case AppRole.admin:
      if (count < 1 || count > maxStoresPerAdmin) {
        errors['stores'] = 'Pilih 1 sampai $maxStoresPerAdmin toko.';
      }
  }

  final password = draft.password;
  if (draft.isCreate && (password == null || password.length < 8)) {
    errors['password'] = 'Password minimal $passwordMinLength karakter.';
  }
  return errors;
}

/// Pembuat password acak. Tanpa karakter yang mudah tertukar (0/O, 1/l/I) agar
/// aman dibacakan atau diketik ulang.
abstract final class PasswordGenerator {
  static const int length = 12;

  static const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const String _digits = '23456789';
  static const String _symbols = '@#\$%&*+?';

  static const List<String> _groups = [_upper, _lower, _digits, _symbols];
  static final String _all = _groups.join();

  /// 12 karakter acak yang aman secara kriptografis; selalu memuat huruf besar,
  /// huruf kecil, angka, dan simbol. [random] hanya untuk tes.
  static String generate({Random? random}) {
    final rng = random ?? Random.secure();
    final chars = <String>[
      for (final group in _groups) group[rng.nextInt(group.length)],
      for (var i = _groups.length; i < length; i++)
        _all[rng.nextInt(_all.length)],
    ]..shuffle(rng);
    return chars.join();
  }
}
