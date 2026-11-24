import 'app_session.dart';
import 'auth_failure.dart';
import 'store_info.dart';

/// Peristiwa sesi: keluar, aktif, atau ditolak.
sealed class SessionEvent {
  const SessionEvent();
}

class SessionSignedOut extends SessionEvent {
  const SessionSignedOut();
}

class SessionActive extends SessionEvent {
  const SessionActive(this.session);

  final AppSession session;
}

class SessionRejected extends SessionEvent {
  const SessionRejected(this.reason);

  final SessionRejection reason;
}

/// Batas antara UI dan Firebase. Implementasi nyata: `FirebaseAuthRepository`;
/// tes memakai repositori palsu.
abstract interface class AuthRepository {
  /// Peristiwa sesi; langsung mengirim keadaan saat ini ketika didengarkan.
  Stream<SessionEvent> watchSession();

  /// Login email + password. Melempar [AuthFailure] dengan pesan siap tampil.
  Future<void> signIn({required String email, required String password});

  /// Mengirim email reset password. Melempar [AuthFailure].
  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  /// Memuat data toko untuk [storeIds], urutannya mengikuti [storeIds].
  Future<List<StoreInfo>> loadStores(List<String> storeIds);
}
