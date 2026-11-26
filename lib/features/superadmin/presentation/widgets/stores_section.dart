import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import '../../state/superadmin_providers.dart';
import '../../state/superadmin_selectors.dart';
import 'directory_data.dart';
import 'management_layout.dart';
import 'store_detail_panel.dart';
import 'store_form_dialog.dart';
import 'store_table.dart';
import 'superadmin_dialogs.dart';
import 'user_form_dialog.dart';

/// Bagian "Toko": ringkasan, tabel toko, dan panel detail toko terpilih.
class StoresSection extends StatelessWidget {
  const StoresSection({super.key, required this.currentUid});

  final String currentUid;

  @override
  Widget build(BuildContext context) => DirectoryData(
    builder: (context, stores, users) =>
        _StoresContent(stores: stores, users: users, currentUid: currentUid),
  );
}

class _StoresContent extends ConsumerWidget {
  const _StoresContent({
    required this.stores,
    required this.users,
    required this.currentUid,
  });

  final List<StoreRecord> stores;
  final List<ManagedUser> users;
  final String currentUid;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final id = await showStoreFormDialog(
      context,
      suggestedCode: suggestStoreCode(stores),
    );
    if (id != null) ref.read(selectedStoreIdProvider.notifier).set(id);
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    StoreRecord store,
    bool active,
  ) async {
    if (!active) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Nonaktifkan ${store.name}?',
        message:
            'Admin dan kasir toko ini tidak bisa memakai toko ini sampai '
            'diaktifkan lagi. Semua data tetap tersimpan.',
        confirmLabel: 'Nonaktifkan',
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }
    await runSuperadminAction(
      context,
      () => ref
          .read(superadminRepositoryProvider)
          .setStoreActive(store.id, isActive: active),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = statsOf(stores, users);
    final query = ref.watch(storeQueryProvider);
    final selected = ref.watch(selectedStoreProvider);
    final visible = filterStores(stores, users, query);

    return ManagementLayout(
      title: 'Toko',
      subtitle: 'Semua toko di aplikasi',
      actionLabel: 'Tambah toko',
      onAction: () => _add(context, ref),
      stats: [
        StatCard(
          compact: true,
          label: 'Toko aktif',
          value: '${stats.activeStores}',
          valueSuffix: 'dari ${stats.totalStores}',
        ),
        StatCard(compact: true, label: 'Admin', value: '${stats.activeAdmins}'),
        StatCard(compact: true, label: 'Kasir', value: '${stats.activeKasirs}'),
      ],
      search: AppTextField(
        hint: 'Cari nama toko, kode, atau admin',
        leading: AppIcons.search,
        initialValue: query,
        onChanged: ref.read(storeQueryProvider.notifier).set,
      ),
      table: stores.isEmpty
          ? StateView(
              icon: AppIcons.store,
              title: 'Belum ada toko',
              message: 'Tambah toko pertama untuk mulai memakai aplikasi.',
              actionLabel: 'Tambah toko',
              onAction: () => _add(context, ref),
            )
          : StoreTable(
              stores: visible,
              staff: {for (final s in stores) s.id: staffOfStore(users, s.id)},
              selectedId: selected?.id,
              onSelect: (s) =>
                  ref.read(selectedStoreIdProvider.notifier).set(s.id),
            ),
      panel: selected == null
          ? null
          : StoreDetailPanel(
              key: ValueKey(selected.id),
              store: selected,
              users: usersOfStore(users, selected.id),
              onToggleActive: (v) => _toggle(context, ref, selected, v),
              onEdit: () => showStoreFormDialog(
                context,
                store: selected,
                suggestedCode: selected.code,
              ),
              onAddUser: () => showUserFormDialog(
                context,
                presetStoreId: selected.id,
                currentUid: currentUid,
              ),
            ),
    );
  }
}
