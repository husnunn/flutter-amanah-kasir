import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/store_record.dart';

/// Tabel toko superadmin: Toko | Admin | Kasir | Status. Baris terpilih
/// berlatar hijau sangat muda.
class StoreTable extends StatelessWidget {
  const StoreTable({
    super.key,
    required this.stores,
    required this.selectedCode,
    required this.onSelect,
  });

  final List<StoreRecord> stores;
  final String? selectedCode;
  final ValueChanged<StoreRecord> onSelect;

  static const int _flexStore = 5;
  static const int _flexAdmin = 2;
  static const int _flexKasir = 1;
  static const int _flexStatus = 2;

  @override
  Widget build(BuildContext context) {
    final head = context.text.labelMedium?.copyWith(color: context.app.ink3);
    Widget cell(int flex, String label, {TextAlign align = TextAlign.start}) =>
        Expanded(
          flex: flex,
          child: Text(label, textAlign: align, style: head),
        );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ColoredBox(
            color: context.app.surfaceAlt,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  cell(_flexStore, 'Toko'),
                  cell(_flexAdmin, 'Admin'),
                  cell(_flexKasir, 'Kasir', align: TextAlign.end),
                  cell(_flexStatus, 'Status'),
                ],
              ),
            ),
          ),
          Expanded(
            child: stores.isEmpty
                ? const StateView(
                    icon: AppIcons.store,
                    title: 'Toko tidak ditemukan',
                    message: 'Coba kata kunci lain.',
                  )
                : ListView.builder(
                    itemCount: stores.length,
                    itemBuilder: (context, i) => _StoreRow(
                      store: stores[i],
                      selected: stores[i].code == selectedCode,
                      onTap: () => onSelect(stores[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final StoreRecord store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? context.app.selectedRow : colors.surface,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.outlineVariant)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Expanded(
                    flex: StoreTable._flexStore,
                    child: Row(
                      spacing: AppSpacing.sm,
                      children: [
                        InitialBlock(
                          label: store.code,
                          tone: ToneName.slate,
                          width: AppSize.chip,
                          height: AppSize.chip,
                          style: text.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
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
                                store.area,
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
                  ),
                  Expanded(
                    flex: StoreTable._flexAdmin,
                    child: Text(
                      store.admin,
                      style: text.bodySmall?.copyWith(color: context.app.ink2),
                    ),
                  ),
                  Expanded(
                    flex: StoreTable._flexKasir,
                    child: Text(
                      '${store.kasirCount}',
                      textAlign: TextAlign.end,
                      style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: StoreTable._flexStatus,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StatusBadge(
                        store.active ? 'Aktif' : 'Nonaktif',
                        tone: store.active
                            ? BadgeTone.success
                            : BadgeTone.neutral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
