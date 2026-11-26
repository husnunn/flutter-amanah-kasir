import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import '../../data/superadmin_failure.dart';
import '../../state/superadmin_providers.dart';

/// Memuat daftar toko dan pengguna sekaligus, lalu menyerahkannya ke [builder].
/// Menangani keadaan memuat dan gagal-muat (dengan tombol Coba lagi).
class DirectoryData extends ConsumerWidget {
  const DirectoryData({super.key, required this.builder});

  final Widget Function(
    BuildContext context,
    List<StoreRecord> stores,
    List<ManagedUser> users,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(managedStoresProvider);
    final users = ref.watch(managedUsersProvider);

    final storeList = stores.value;
    final userList = users.value;
    if (storeList != null && userList != null) {
      return builder(context, storeList, userList);
    }

    final error = stores.error ?? users.error;
    if (error != null) {
      return StateView(
        icon: AppIcons.alertTriangle,
        title: 'Data belum bisa dimuat',
        message: error is SuperadminFailure
            ? error.message
            : 'Periksa koneksi internet lalu coba lagi.',
        actionLabel: 'Coba lagi',
        onAction: () {
          ref
            ..invalidate(managedStoresProvider)
            ..invalidate(managedUsersProvider);
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
