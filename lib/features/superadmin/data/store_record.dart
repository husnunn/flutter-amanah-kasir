import 'package:flutter/foundation.dart';

/// Toko di sisi superadmin (dokumen `stores/{id}`).
@immutable
class StoreRecord {
  const StoreRecord({
    required this.id,
    required this.code,
    required this.name,
    this.address = '',
    this.phone = '',
    this.isActive = true,
    this.scanEnabled = false,
    this.createdAt,
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final String phone;
  final bool isActive;
  final bool scanEnabled;
  final DateTime? createdAt;

  StoreRecord copyWith({
    String? name,
    String? address,
    String? phone,
    bool? isActive,
    bool? scanEnabled,
  }) => StoreRecord(
    id: id,
    code: code,
    name: name ?? this.name,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    isActive: isActive ?? this.isActive,
    scanEnabled: scanEnabled ?? this.scanEnabled,
    createdAt: createdAt,
  );
}

/// Isian form toko. [id] null = toko baru.
@immutable
class StoreDraft {
  const StoreDraft({
    this.id,
    required this.code,
    required this.name,
    this.address = '',
    this.phone = '',
    this.scanEnabled = false,
  });

  final String? id;
  final String code;
  final String name;
  final String address;
  final String phone;
  final bool scanEnabled;

  bool get isCreate => id == null;
}

final RegExp _codePattern = RegExp(r'^[A-Z0-9]{2,8}$');
final RegExp _phonePattern = RegExp(r'^[0-9+()\-\s]*$');

const int storeNameMin = 2;
const int storeNameMax = 60;
const int storeAddressMax = 120;
const int storePhoneMax = 20;

/// Pesan error per field ('code', 'name', 'address', 'phone'); kosong = valid.
/// Aturannya sama dengan `functions/src/stores.js` supaya error tampil di form
/// sebelum permintaan dikirim.
Map<String, String> validateStoreDraft(StoreDraft draft) {
  final errors = <String, String>{};

  final name = draft.name.trim();
  if (name.length < storeNameMin || name.length > storeNameMax) {
    errors['name'] = 'Nama toko $storeNameMin-$storeNameMax karakter.';
  }

  if (draft.isCreate) {
    final code = draft.code.trim().toUpperCase();
    if (code.isEmpty) {
      errors['code'] = 'Kode toko wajib diisi.';
    } else if (!_codePattern.hasMatch(code)) {
      errors['code'] = 'Kode 2-8 karakter huruf atau angka, tanpa spasi.';
    }
  }

  if (draft.address.trim().length > storeAddressMax) {
    errors['address'] = 'Alamat maksimal $storeAddressMax karakter.';
  }

  final phone = draft.phone.trim();
  if (phone.length > storePhoneMax || !_phonePattern.hasMatch(phone)) {
    errors['phone'] = 'Telepon maksimal $storePhoneMax karakter (angka, +, -).';
  }
  return errors;
}

final RegExp _suggestedCode = RegExp(r'^TK(\d+)$');

/// Kode berikutnya untuk toko baru: TK + nomor terbesar yang ada + 1 ("TK09").
String suggestStoreCode(Iterable<StoreRecord> stores) {
  var highest = 0;
  for (final store in stores) {
    final match = _suggestedCode.firstMatch(store.code);
    if (match == null) continue;
    final number = int.parse(match.group(1)!);
    if (number > highest) highest = number;
  }
  return 'TK${(highest + 1).toString().padLeft(2, '0')}';
}
