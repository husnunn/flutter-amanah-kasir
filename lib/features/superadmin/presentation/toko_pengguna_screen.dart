import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/new_user_input.dart';
import '../data/store_record.dart';
import '../data/superadmin_repository.dart';
import 'widgets/add_user_dialog.dart';
import 'widgets/store_detail_panel.dart';
import 'widgets/store_table.dart';

const _superadminNav = <NavItem>[
  NavItem(icon: AppIcons.dashboard, label: 'Ringkasan'),
  NavItem(icon: AppIcons.store, label: 'Toko'),
  NavItem(icon: AppIcons.users, label: 'Pengguna'),
  NavItem(icon: AppIcons.sliders, label: 'Pengaturan aplikasi'),
];

/// Mengubah status aktif toko. Melempar [SuperadminFailure] bila gagal.
typedef SetStoreActive = Future<void> Function(StoreRecord store, bool active);

/// Superadmin - Toko & pengguna (tablet): sidebar gelap | ringkasan + tabel
/// toko | panel detail toko terpilih.
///
/// Tampilan murni: data datang dari [stores] (lihat `TokoPenggunaPage` untuk
/// yang terhubung ke Firestore). Perubahan status toko diteruskan ke
/// [onSetActive]; daftar baru tiba lewat [stores].
class TokoPenggunaScreen extends StatefulWidget {
  const TokoPenggunaScreen({
    super.key,
    required this.stores,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
    this.onSetActive,
    this.onCreateUser,
    this.userName = 'Pemilik aplikasi',
    this.onLogout,
  });

  final List<StoreRecord> stores;
  final bool isLoading;

  /// Gagal memuat dan belum ada data sama sekali.
  final bool hasError;
  final VoidCallback? onRetry;
  final SetStoreActive? onSetActive;

  /// Null = tombol "Tambah pengguna" hanya menampilkan "segera hadir".
  final CreateUser? onCreateUser;
  final String userName;
  final VoidCallback? onLogout;

  @override
  State<TokoPenggunaScreen> createState() => _TokoPenggunaScreenState();
}

class _TokoPenggunaScreenState extends State<TokoPenggunaScreen> {
  String? _selectedId;
  String _query = '';

  /// Toko yang statusnya sedang diubah (sakelar dikunci sampai selesai).
  final Set<String> _busy = {};

  List<StoreRecord> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.stores;
    return widget.stores
        .where(
          (s) =>
              s.name.toLowerCase().contains(q) ||
              s.code.toLowerCase().contains(q) ||
              s.admins.any((a) => a.name.toLowerCase().contains(q)),
        )
        .toList();
  }

  /// Toko terpilih; bila belum memilih (atau tokonya hilang) toko pertama.
  StoreRecord? get _selected {
    for (final s in widget.stores) {
      if (s.id == _selectedId) return s;
    }
    return widget.stores.firstOrNull;
  }

  Future<void> _setActive(StoreRecord store, bool active) async {
    final handler = widget.onSetActive;
    if (handler == null || _busy.contains(store.id)) return;
    setState(() => _busy.add(store.id));
    try {
      await handler(store, active);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error is SuperadminFailure
                  ? error.message
                  : 'Gagal mengubah status toko. Coba lagi.',
            ),
          ),
        );
    } finally {
      if (mounted) setState(() => _busy.remove(store.id));
    }
  }

  Future<void> _addUser(StoreRecord store) async {
    final create = widget.onCreateUser;
    if (create == null) return showComingSoon(context, 'Tambah pengguna');
    final name = await showAddUserDialog(
      context,
      stores: widget.stores,
      initialStoreId: store.id,
      onSubmit: create,
    );
    if (name == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$name ditambahkan.')));
  }

  @override
  Widget build(BuildContext context) {
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
              userName: widget.userName,
              userRole: 'Superadmin',
              userInitials: initialsOf(widget.userName),
              onLogout: widget.onLogout,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  spacing: AppSpacing.lg,
                  children: [
                    Expanded(child: _buildMain(context)),
                    if (_showDetail)
                      SizedBox(
                        width: AppLayout.editPanel,
                        child: StoreDetailPanel(
                          key: ValueKey(_selected!.id),
                          store: _selected!,
                          busy: _busy.contains(_selected!.id),
                          onToggleActive: widget.onSetActive == null
                              ? null
                              : (v) => _setActive(_selected!, v),
                          onAddUser: () => _addUser(_selected!),
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

  bool get _showDetail =>
      !widget.isLoading && !widget.hasError && _selected != null;

  Widget _buildMain(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        _buildHeader(context),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toko', style: context.text.headlineMedium),
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
          onPressed: () => showComingSoon(context, 'Tambah toko'),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.hasError) {
      return StateView(
        icon: AppIcons.alertTriangle,
        title: 'Tidak bisa memuat toko',
        message: 'Periksa koneksi internet Anda, lalu coba lagi.',
        actionLabel: widget.onRetry == null ? null : 'Coba lagi',
        onAction: widget.onRetry,
      );
    }
    if (widget.stores.isEmpty) {
      return const StateView(
        icon: AppIcons.store,
        title: 'Belum ada toko',
        message: 'Toko yang dibuat akan muncul di sini.',
      );
    }

    final admins = {
      for (final s in widget.stores)
        for (final a in s.admins) a.uid,
    }.length;
    final kasirs = widget.stores.fold<int>(0, (sum, s) => sum + s.kasirCount);
    final activeCount = widget.stores.where((s) => s.active).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: StatCard(
                compact: true,
                label: 'Toko aktif',
                value: '$activeCount',
                valueSuffix: 'dari ${widget.stores.length}',
              ),
            ),
            Expanded(
              child: StatCard(compact: true, label: 'Admin', value: '$admins'),
            ),
            Expanded(
              child: StatCard(compact: true, label: 'Kasir', value: '$kasirs'),
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
            selectedId: _selected?.id,
            onSelect: (s) => setState(() => _selectedId = s.id),
          ),
        ),
      ],
    );
  }
}
