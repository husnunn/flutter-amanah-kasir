import 'managed_user.dart';
import 'store_record.dart';

/// Akses data kelola toko dan pengguna (superadmin).
///
/// Semua kegagalan dilempar sebagai `SuperadminFailure` dengan pesan siap tampil.
abstract interface class SuperadminRepository {
  /// Semua toko, urut kode. Realtime: perubahan dari Cloud Function langsung muncul.
  Stream<List<StoreRecord>> watchStores();

  /// Semua pengguna, urut nama. Realtime.
  Stream<List<ManagedUser>> watchUsers();

  /// Jumlah transaksi toko pada bulan berjalan.
  Future<int> monthlyTransactions(String storeId);

  /// Membuat (id null) atau mengubah toko. Mengembalikan id toko.
  Future<String> saveStore(StoreDraft draft);

  Future<void> setStoreActive(String storeId, {required bool isActive});

  /// Membuat (uid null) atau mengubah pengguna. Mengembalikan uid.
  Future<String> saveUser(UserDraft draft);

  Future<void> setUserActive(String uid, {required bool isActive});

  /// Mengirim email tautan reset password ke [email].
  Future<void> sendPasswordReset(String email);
}
