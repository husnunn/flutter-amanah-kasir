import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../auth/data/app_role.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import '../../state/superadmin_providers.dart';
import '../../state/superadmin_selectors.dart';
import 'directory_data.dart';
import 'management_layout.dart';
import 'superadmin_dialogs.dart';
import 'user_detail_panel.dart';
import 'user_form_dialog.dart';
import 'user_table.dart';

/// Pilihan filter peran; indeks 0 = semua.
const _roleFilters = <AppRole?>[
  null,
  AppRole.admin,
  AppRole.kasir,
  AppRole.superadmin,
];

/// Bagian "Pengguna": ringkasan, tabel pengguna (filter peran + pencarian),
/// dan panel detail pengguna terpilih.
class UsersSection extends StatelessWidget {
  const UsersSection({super.key, required this.currentUid});

  final String currentUid;

  @override
  Widget build(BuildContext context) => DirectoryData(
    builder: (context, stores, users) =>
        _UsersContent(stores: stores, users: users, currentUid: currentUid),
  );
}

class _UsersContent extends ConsumerWidget {
  const _UsersContent({
    required this.stores,
    required this.users,
    required this.currentUid,
  });

  final List<StoreRecord> stores;
  final List<ManagedUser> users;
  final String currentUid;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final uid = await showUserFormDialog(context, currentUid: currentUid);
    if (uid != null) ref.read(selectedUserIdProvider.notifier).set(uid);
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    ManagedUser user,
  ) async {
    final repository = ref.read(superadminRepositoryProvider);
    if (user.isActive) {
      final confirmed = await showConfirmDialog(
        context,
        title: 'Nonaktifkan ${user.name}?',
        message:
            '${user.name} langsung keluar dan tidak bisa masuk lagi sampai '
            'akunnya diaktifkan kembali.',
        confirmLabel: 'Nonaktifkan',
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;
    }
    await runSuperadminAction(
      context,
      () => repository.setUserActive(user.uid, isActive: !user.isActive),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = users.where((u) => u.isActive).length;
    final stats = statsOf(stores, users);
    final query = ref.watch(userQueryProvider);
    final role = ref.watch(userRoleFilterProvider);
    final selected = ref.watch(selectedUserProvider);
    final visible = filterUsers(users, stores, query, role: role);

    return ManagementLayout(
      title: 'Pengguna',
      subtitle: 'Admin dan kasir di semua toko',
      actionLabel: 'Tambah pengguna',
      onAction: () => _add(context, ref),
      stats: [
        StatCard(
          compact: true,
          label: 'Pengguna aktif',
          value: '$active',
          valueSuffix: 'dari ${users.length}',
        ),
        StatCard(compact: true, label: 'Admin', value: '${stats.activeAdmins}'),
        StatCard(compact: true, label: 'Kasir', value: '${stats.activeKasirs}'),
      ],
      search: AppTextField(
        hint: 'Cari nama, email, atau kode toko',
        leading: AppIcons.search,
        initialValue: query,
        onChanged: ref.read(userQueryProvider.notifier).set,
      ),
      // Bisa digulir: di tablet kecil atau font besar, empat segmen tidak muat.
      filter: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SegmentedTabs(
          labels: ['Semua', for (final r in _roleFilters.skip(1)) r!.label],
          selectedIndex: _roleFilters.indexOf(role),
          onChanged: (i) =>
              ref.read(userRoleFilterProvider.notifier).set(_roleFilters[i]),
        ),
      ),
      table: UserTable(
        users: visible,
        stores: stores,
        selectedId: selected?.uid,
        currentUid: currentUid,
        onSelect: (u) => ref.read(selectedUserIdProvider.notifier).set(u.uid),
      ),
      panel: selected == null
          ? null
          : UserDetailPanel(
              key: ValueKey(selected.uid),
              user: selected,
              stores: stores,
              isSelf: selected.uid == currentUid,
              onEdit: () => showUserFormDialog(
                context,
                user: selected,
                currentUid: currentUid,
              ),
              onSendReset: () => runSuperadminAction(
                context,
                () => ref
                    .read(superadminRepositoryProvider)
                    .sendPasswordReset(selected.email),
                successMessage: 'Tautan reset dikirim ke ${selected.email}.',
              ),
              onToggleActive: () => _toggle(context, ref, selected),
            ),
    );
  }
}
