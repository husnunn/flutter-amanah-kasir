import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_role.dart';
import '../data/app_session.dart';
import '../data/auth_failure.dart';
import '../data/auth_repository.dart';
import '../data/firebase_auth_repository.dart';
import '../data/store_info.dart';

/// Repositori auth. Ditimpa dengan repositori palsu pada tes.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

// ---------------------------------------------------------------------------
// Status sesi
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

/// Menunggu status sesi pertama dari Firebase.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Belum masuk. [notice] berisi alasan bila sesi barusan ditolak.
class AuthSignedOut extends AuthState {
  const AuthSignedOut({this.notice});

  final String? notice;
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn(this.session);

  final AppSession session;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.watchSession().listen(
      _onEvent,
      onError: (Object _) => state = const AuthSignedOut(
        notice: 'Tidak bisa memuat sesi. Periksa koneksi internet.',
      ),
    );
    ref.onDispose(subscription.cancel);
    return const AuthLoading();
  }

  void _onEvent(SessionEvent event) {
    switch (event) {
      case SessionSignedOut():
        // Pertahankan alasan penolakan agar tetap tampil di layar Login.
        final current = state;
        if (current is AuthSignedOut && current.notice != null) return;
        state = const AuthSignedOut();
      case SessionActive(:final session):
        final current = state;
        // Penyegaran token berkala tidak boleh dianggap sesi baru.
        if (current is AuthSignedIn && current.session == session) return;
        state = AuthSignedIn(session);
      case SessionRejected(:final reason):
        state = AuthSignedOut(notice: reason.message);
        unawaited(ref.read(authRepositoryProvider).signOut());
    }
  }

  void clearNotice() {
    if (state case AuthSignedOut(notice: != null)) {
      state = const AuthSignedOut();
    }
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

// ---------------------------------------------------------------------------
// Form login
// ---------------------------------------------------------------------------

class LoginState {
  const LoginState({this.isLoading = false, this.error});

  final bool isLoading;
  final String? error;
}

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() {
    // Setelah login berhasil tombol tetap "memuat" sampai sesi selesai
    // diperiksa; begitu status sesi berubah (masuk/ditolak) form dibuka lagi.
    ref.listen(authControllerProvider, (previous, next) {
      if (next is! AuthLoading && state.isLoading) {
        state = const LoginState();
      }
    });
    return const LoginState();
  }

  Future<void> signIn(String email, String password) async {
    if (state.isLoading) return;
    state = const LoginState(isLoading: true);
    ref.read(authControllerProvider.notifier).clearNotice();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
    } on AuthFailure catch (failure) {
      state = LoginState(error: failure.message);
    } catch (_) {
      state = const LoginState(error: 'Terjadi kendala saat masuk. Coba lagi.');
    }
  }

  /// Mengirim email reset password. Mengembalikan pesan error, atau null bila berhasil.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      return null;
    } on AuthFailure catch (failure) {
      return failure.message;
    } catch (_) {
      return 'Tidak bisa mengirim email. Coba lagi.';
    }
  }
}

final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);

// ---------------------------------------------------------------------------
// Toko aktif
// ---------------------------------------------------------------------------

/// Toko yang sedang dikerjakan. Kasir dan admin satu toko otomatis; admin
/// multi-toko memilih lewat layar Pilih toko; superadmin tidak punya toko aktif.
class ActiveStoreController extends Notifier<String?> {
  @override
  String? build() {
    final auth = ref.watch(authControllerProvider);
    if (auth is! AuthSignedIn) return null;
    final session = auth.session;
    if (session.role == AppRole.superadmin) return null;
    return session.storeIds.length == 1 ? session.storeIds.first : null;
  }

  void select(String storeId) => state = storeId;

  void clear() => state = null;
}

final activeStoreIdProvider = NotifierProvider<ActiveStoreController, String?>(
  ActiveStoreController.new,
);

/// Data toko milik sesi (kosong untuk superadmin).
final storesProvider = FutureProvider<List<StoreInfo>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth is! AuthSignedIn || auth.session.role == AppRole.superadmin) {
    return const [];
  }
  return ref.watch(authRepositoryProvider).loadStores(auth.session.storeIds);
});
