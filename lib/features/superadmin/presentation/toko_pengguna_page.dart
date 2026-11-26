import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../state/superadmin_providers.dart';
import 'toko_pengguna_screen.dart';

/// Toko & pengguna superadmin yang terhubung ke Firestore.
class TokoPenggunaPage extends ConsumerWidget {
  const TokoPenggunaPage({
    super.key,
    this.userName = 'Pemilik aplikasi',
    this.onLogout,
  });

  final String userName;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(storeRecordsProvider);
    // Saat sudah punya data, error susulan (mis. koneksi putus sebentar) tidak
    // mengosongkan layar; Firestore menyambung ulang sendiri.
    final hasData = records.hasValue;
    return TokoPenggunaScreen(
      stores: records.value ?? const [],
      isLoading: records.isLoading && !hasData,
      hasError: records.hasError && !hasData,
      onRetry: () => ref.invalidate(storeRecordsProvider),
      onSetActive: (store, active) => ref
          .read(superadminRepositoryProvider)
          .setStoreActive(store.id, active),
      onCreateUser: (input) =>
          ref.read(superadminRepositoryProvider).createUser(input),
      userName: userName,
      onLogout: onLogout,
    );
  }
}
