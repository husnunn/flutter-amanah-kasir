import 'dart:async';

import 'package:amanah_kasir/features/auth/data/app_role.dart';
import 'package:amanah_kasir/features/auth/data/app_session.dart';
import 'package:amanah_kasir/features/auth/data/auth_failure.dart';
import 'package:amanah_kasir/features/auth/data/auth_repository.dart';
import 'package:amanah_kasir/features/auth/data/store_info.dart';

/// Akun palsu: password + peristiwa sesi yang muncul setelah login berhasil.
class FakeAccount {
  const FakeAccount(this.password, this.event);

  final String password;
  final SessionEvent event;
}

/// Repositori auth tanpa Firebase untuk tes.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.accounts = const {}, this.stores = const []});

  final Map<String, FakeAccount> accounts;
  final List<StoreInfo> stores;

  final _controller = StreamController<SessionEvent>.broadcast();
  SessionEvent current = const SessionSignedOut();

  /// Bila diisi, signIn menunggu sampai selesai (untuk menguji status memuat).
  Completer<void>? signInGate;

  int signInCalls = 0;
  int signOutCalls = 0;
  final List<String> resetRequests = [];
  AuthFailure? resetFailure;

  void emit(SessionEvent event) {
    current = event;
    _controller.add(event);
  }

  @override
  Stream<SessionEvent> watchSession() async* {
    yield current;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
    if (signInGate != null) await signInGate!.future;
    final account = accounts[email.trim()];
    if (account == null || account.password != password) {
      throw const AuthFailure('Email atau password salah.');
    }
    emit(account.event);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (resetFailure != null) throw resetFailure!;
    resetRequests.add(email.trim());
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    emit(const SessionSignedOut());
  }

  @override
  Future<List<StoreInfo>> loadStores(List<String> storeIds) async => [
    for (final id in storeIds) ...stores.where((store) => store.id == id),
  ];
}

AppSession session(
  AppRole role, {
  List<String> storeIds = const ['tk01'],
  String name = 'Rina Wati',
  String uid = 'u1',
}) => AppSession(
  uid: uid,
  email: '$uid@amanah.test',
  name: name,
  role: role,
  storeIds: storeIds,
);

const demoStores = [
  StoreInfo(
    id: 'tk01',
    code: 'TK01',
    name: 'Toko Berkah Jaya',
    address: 'Surabaya',
  ),
  StoreInfo(
    id: 'tk02',
    code: 'TK02',
    name: 'Warung Bu Sri',
    address: 'Sidoarjo',
  ),
];
