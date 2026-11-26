import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/store_record.dart';
import '../../state/superadmin_selectors.dart';
import 'directory_table_parts.dart';

const _columns = [
  DirectoryColumn('Toko', 5),
  DirectoryColumn('Admin', 3),
  DirectoryColumn('Kasir', 1, alignEnd: true),
  DirectoryColumn('Status', 2),
];

/// Tabel toko: Toko | Admin | Kasir | Status. [staff] berisi ringkasan staf
/// aktif per id toko.
class StoreTable extends StatelessWidget {
  const StoreTable({
    super.key,
    required this.stores,
    required this.staff,
    required this.selectedId,
    required this.onSelect,
  });

  final List<StoreRecord> stores;
  final Map<String, StoreStaff> staff;
  final String? selectedId;
  final ValueChanged<StoreRecord> onSelect;

  @override
  Widget build(BuildContext context) {
    return DirectoryTable(
      columns: _columns,
      child: stores.isEmpty
          ? const StateView(
              icon: AppIcons.store,
              title: 'Toko tidak ditemukan',
              message: 'Coba kata kunci lain.',
            )
          : ListView.builder(
              itemCount: stores.length,
              itemBuilder: (context, i) {
                final store = stores[i];
                return _StoreRow(
                  store: store,
                  staff: staff[store.id],
                  selected: store.id == selectedId,
                  onTap: () => onSelect(store),
                );
              },
            ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.staff,
    required this.selected,
    required this.onTap,
  });

  final StoreRecord store;
  final StoreStaff? staff;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    return DirectoryRow(
      columns: _columns,
      selected: selected,
      onTap: onTap,
      cells: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            InitialBlock(
              label: store.code,
              tone: ToneName.slate,
              width: AppSize.chip,
              height: AppSize.chip,
              style: text.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    store.address.isEmpty ? '-' : store.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          staff?.adminLabel ?? '-',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.bodySmall?.copyWith(color: context.app.ink2),
        ),
        Text(
          '${staff?.kasirCount ?? 0}',
          textAlign: TextAlign.end,
          style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        FitCell(
          child: StatusBadge(
            store.isActive ? 'Aktif' : 'Nonaktif',
            tone: store.isActive ? BadgeTone.success : BadgeTone.neutral,
          ),
        ),
      ],
    );
  }
}
