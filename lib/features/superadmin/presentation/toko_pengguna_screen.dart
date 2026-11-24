import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/widgets/widgets.dart';
import '../data/sample_store_records.dart';
import '../data/store_record.dart';
import 'widgets/store_detail_panel.dart';
import 'widgets/store_table.dart';

const _superadminNav = <NavItem>[
  NavItem(icon: AppIcons.dashboard, label: 'Ringkasan'),
  NavItem(icon: AppIcons.store, label: 'Toko'),
  NavItem(icon: AppIcons.users, label: 'Pengguna'),
  NavItem(icon: AppIcons.sliders, label: 'Pengaturan aplikasi'),
];

/// Superadmin - Toko & pengguna (tablet): sidebar gelap | ringkasan + tabel
/// toko | panel detail toko terpilih. Perubahan hanya di memori layar ini.
class TokoPenggunaScreen extends StatefulWidget {
  const TokoPenggunaScreen({
    super.key,
    this.initialStores = sampleStoreRecords,
    this.initialSelectedCode = 'TK01',
    this.onLogout,
  });

  final List<StoreRecord> initialStores;
  final String? initialSelectedCode;
  final VoidCallback? onLogout;

  @override
  State<TokoPenggunaScreen> createState() => _TokoPenggunaScreenState();
}

class _TokoPenggunaScreenState extends State<TokoPenggunaScreen> {
  late List<StoreRecord> _stores = widget.initialStores;
  late String? _selectedCode = widget.initialSelectedCode;
  String _query = '';

  List<StoreRecord> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _stores;
    return _stores
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q) ||
              s.admin.toLowerCase().contains(q),
        )
        .toList();
  }

  StoreRecord? get _selected {
    for (final s in _stores) {
      if (s.code == _selectedCode) return s;
    }
    return null;
  }

  void _setActive(StoreRecord store, bool active) {
    setState(() {
      _stores = [
        for (final s in _stores)
          s.code == store.code ? s.copyWith(active: active) : s,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final admins = _stores.map((s) => s.admin).toSet().length;
    final kasirs = _stores.fold<int>(0, (sum, s) => sum + s.kasirCount);
    final activeCount = _stores.where((s) => s.active).length;

    return TabletOnly(
      child: Scaffold(
        body: Row(
          children: [
            AppSidebar(
              dark: true,
              badgeLabel: 'SUPERADMIN',
              items: _superadminNav,
              selectedIndex: 1,
              onSelected: (i) {
                if (i != 1) showComingSoon(context, _superadminNav[i].label);
              },
              userName: 'Pemilik aplikasi',
              userRole: 'Superadmin',
              userInitials: 'PA',
              onLogout: widget.onLogout,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  spacing: AppSpacing.lg,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.md,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Toko',
                                    style: context.text.headlineMedium,
                                  ),
                                  Text(
                                    'Semua toko di aplikasi',
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              AppButton(
                                label: 'Tambah toko',
                                icon: AppIcons.plus,
                                size: AppButtonSize.small,
                                expand: false,
                                onPressed: () =>
                                    showComingSoon(context, 'Tambah toko'),
                              ),
                            ],
                          ),
                          Row(
                            spacing: AppSpacing.sm,
                            children: [
                              Expanded(
                                child: StatCard(
                                  compact: true,
                                  label: 'Toko aktif',
                                  value: '$activeCount',
                                  valueSuffix: 'dari ${_stores.length}',
                                ),
                              ),
                              Expanded(
                                child: StatCard(
                                  compact: true,
                                  label: 'Admin',
                                  value: '$admins',
                                ),
                              ),
                              Expanded(
                                child: StatCard(
                                  compact: true,
                                  label: 'Kasir',
                                  value: '$kasirs',
                                ),
                              ),
                            ],
                          ),
                          AppTextField(
                            hint: 'Cari nama toko, kode, atau admin',
                            leading: AppIcons.search,
                            onChanged: (q) => setState(() => _query = q),
                          ),
                          Expanded(
                            child: StoreTable(
                              stores: _visible,
                              selectedCode: _selectedCode,
                              onSelect: (s) =>
                                  setState(() => _selectedCode = s.code),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected != null)
                      SizedBox(
                        width: AppLayout.editPanel,
                        child: StoreDetailPanel(
                          key: ValueKey(selected.code),
                          store: selected,
                          onToggleActive: (v) => _setActive(selected, v),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
