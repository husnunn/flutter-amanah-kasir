import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/app_role.dart';
import '../data/firebase_superadmin_repository.dart';
import '../data/managed_user.dart';
import '../data/store_record.dart';
import '../data/superadmin_repository.dart';
import 'superadmin_selectors.dart';

/// Repositori kelola toko/pengguna. Ditimpa dengan repositori contoh di galeri
/// dan tes.
final superadminRepositoryProvider = Provider<SuperadminRepository>(
  (ref) => FirebaseSuperadminRepository(),
);

/// Riverpod 3 mengulang provider yang gagal secara otomatis. Aliran Firestore
/// yang gagal biasanya permanen (mis. tidak berhak), jadi pengulangan diam-diam
/// hanya menimpa pesan error; pengguna mengulang lewat tombol "Coba lagi".
Duration? _noRetry(int retryCount, Object error) => null;

/// Daftar toko dan pengguna secara realtime. Nama sengaja berbeda dari
/// `storesProvider` milik auth (toko milik sesi).
final managedStoresProvider = StreamProvider<List<StoreRecord>>(
  (ref) => ref.watch(superadminRepositoryProvider).watchStores(),
  retry: _noRetry,
);

final managedUsersProvider = StreamProvider<List<ManagedUser>>(
  (ref) => ref.watch(superadminRepositoryProvider).watchUsers(),
  retry: _noRetry,
);

/// Nilai tunggal yang bisa diubah dari layar (bagian aktif, pilihan, pencarian).
class ValueController<T> extends Notifier<T> {
  ValueController(this._initial);

  final T _initial;

  @override
  T build() => _initial;

  // ignore: use_setters_to_change_properties
  void set(T value) => state = value;
}

NotifierProvider<ValueController<T>, T> _value<T>(T initial) =>
    NotifierProvider<ValueController<T>, T>(() => ValueController(initial));

enum SuperadminSection { stores, users }

final superadminSectionProvider = _value(SuperadminSection.stores);

/// Id toko/pengguna yang dipilih. Null = baris pertama daftar (lihat
/// [selectedStoreProvider] dan [selectedUserProvider]).
final selectedStoreIdProvider = _value<String?>(null);
final selectedUserIdProvider = _value<String?>(null);

final storeQueryProvider = _value('');
final userQueryProvider = _value('');

/// Filter peran daftar pengguna; null = semua.
final userRoleFilterProvider = _value<AppRole?>(null);

/// Toko terpilih; bila belum dipilih atau sudah tidak ada, toko pertama.
final selectedStoreProvider = Provider<StoreRecord?>((ref) {
  final stores = ref.watch(managedStoresProvider).value ?? const [];
  final id = ref.watch(selectedStoreIdProvider);
  return stores.where((s) => s.id == id).firstOrNull ?? stores.firstOrNull;
});

final selectedUserProvider = Provider<ManagedUser?>((ref) {
  final users = ref.watch(managedUsersProvider).value ?? const [];
  final id = ref.watch(selectedUserIdProvider);
  return users.where((u) => u.uid == id).firstOrNull ?? users.firstOrNull;
});

final superadminStatsProvider = Provider<SuperadminStats?>((ref) {
  final stores = ref.watch(managedStoresProvider).value;
  final users = ref.watch(managedUsersProvider).value;
  if (stores == null || users == null) return null;
  return statsOf(stores, users);
});

/// Transaksi bulan ini untuk satu toko; dimuat saat panel detail dibuka.
final monthlyTransactionsProvider = FutureProvider.family<int, String>(
  (ref, storeId) =>
      ref.watch(superadminRepositoryProvider).monthlyTransactions(storeId),
);
