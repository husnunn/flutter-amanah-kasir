import 'dart:async';

import 'package:amanah_kasir/features/superadmin/data/new_user_input.dart';
import 'package:amanah_kasir/features/superadmin/data/store_record.dart';
import 'package:amanah_kasir/features/superadmin/data/superadmin_repository.dart';

/// Repositori superadmin tanpa Firebase untuk tes.
///
/// Mensimulasikan Firestore: [setStoreActive] dan [createUser] mengubah daftar
/// lalu memancarkannya lagi, seperti snapshot yang tiba setelah dokumen ditulis.
class FakeSuperadminRepository implements SuperadminRepository {
  /// [initial] null = belum ada data (layar tetap memuat) sampai [emit].
  FakeSuperadminRepository({List<StoreRecord>? initial}) : current = initial;

  final _controller = StreamController<List<StoreRecord>>.broadcast();
  List<StoreRecord>? current;

  /// Bila diisi, [watchStores] langsung gagal dengan error ini.
  Object? watchError;

  /// Bila diisi, [setStoreActive] melempar ini.
  Object? toggleFailure;

  /// Bila diisi, [setStoreActive] menunggu sampai selesai.
  Completer<void>? toggleGate;

  /// Bila diisi, [createUser] melempar ini.
  Object? createFailure;

  int watchCalls = 0;
  final List<(String, bool)> toggles = [];
  final List<NewUserInput> created = [];

  void emit(List<StoreRecord> stores) {
    current = stores;
    _controller.add(stores);
  }

  @override
  Stream<List<StoreRecord>> watchStores() {
    watchCalls++;
    return _stream();
  }

  Stream<List<StoreRecord>> _stream() async* {
    final error = watchError;
    if (error != null) throw error;
    final snapshot = current;
    if (snapshot != null) yield snapshot;
    yield* _controller.stream;
  }

  @override
  Future<void> setStoreActive(String storeId, bool isActive) async {
    toggles.add((storeId, isActive));
    if (toggleGate != null) await toggleGate!.future;
    final failure = toggleFailure;
    if (failure != null) throw failure;
    emit([
      for (final s in current ?? const <StoreRecord>[])
        s.id == storeId ? s.copyWith(active: isActive) : s,
    ]);
  }

  @override
  Future<void> createUser(NewUserInput input) async {
    created.add(input);
    final failure = createFailure;
    if (failure != null) throw failure;
    emit([
      for (final s in current ?? const <StoreRecord>[])
        if (input.storeIds.contains(s.id))
          s.withUser(
            StoreUser(
              uid: 'baru-${created.length}',
              initials: input.cleanName.substring(0, 1).toUpperCase(),
              name: input.cleanName,
              note: input.cleanEmail,
              role: input.role,
            ),
          )
        else
          s,
    ]);
  }
}
