import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import '../../state/superadmin_selectors.dart';
import 'detail_parts.dart';
import 'directory_table_parts.dart';

const _columns = [
  DirectoryColumn('Pengguna', 5),
  DirectoryColumn('Peran', 2),
  DirectoryColumn('Toko', 3),
  DirectoryColumn('Status', 2),
];

/// Tabel pengguna: Pengguna | Peran | Toko (kode) | Status. [currentUid] diberi
/// tanda "Anda".
class UserTable extends StatelessWidget {
  const UserTable({
    super.key,
    required this.users,
    required this.stores,
    required this.selectedId,
    required this.currentUid,
    required this.onSelect,
  });

  final List<ManagedUser> users;
  final List<StoreRecord> stores;
  final String? selectedId;
  final String currentUid;
  final ValueChanged<ManagedUser> onSelect;

  @override
  Widget build(BuildContext context) {
    return DirectoryTable(
      columns: _columns,
      child: users.isEmpty
          ? const StateView(
              icon: AppIcons.users,
              title: 'Pengguna tidak ditemukan',
              message: 'Coba kata kunci atau filter peran lain.',
            )
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, i) {
                final user = users[i];
                return _UserRow(
                  user: user,
                  storeLabel: storeCodesLabel(user, stores),
                  isSelf: user.uid == currentUid,
                  selected: user.uid == selectedId,
                  onTap: () => onSelect(user),
                );
              },
            ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.storeLabel,
    required this.isSelf,
    required this.selected,
    required this.onTap,
  });

  final ManagedUser user;
  final String storeLabel;
  final bool isSelf;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return DirectoryRow(
      columns: _columns,
      selected: selected,
      onTap: onTap,
      cells: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            InitialAvatar(user.initials, size: AppSize.chip),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        user.name,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelf)
                        const StatusBadge('Anda', tone: BadgeTone.info),
                    ],
                  ),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        FitCell(child: RoleBadge(user.role)),
        Text(
          storeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.bodySmall?.copyWith(color: context.app.ink2),
        ),
        FitCell(
          child: StatusBadge(
            user.isActive ? 'Aktif' : 'Nonaktif',
            tone: user.isActive ? BadgeTone.success : BadgeTone.neutral,
          ),
        ),
      ],
    );
  }
}
