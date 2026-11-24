import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/widgets/widgets.dart';
import '../../admin/presentation/admin_nav.dart';
import '../data/product.dart';
import 'widgets/product_edit_panel.dart';
import 'widgets/product_filters.dart';
import 'widgets/product_table.dart';

/// Kelola produk (tablet): sidebar admin | daftar + filter | panel edit 340.
/// Perubahan hanya disimpan di memori layar ini (belum ada backend).
class ProdukScreen extends StatefulWidget {
  const ProdukScreen({
    super.key,
    this.initialProducts = sampleProducts,
    this.initialSelectedId = 'telur',
    this.storeName = 'Toko Berkah Jaya',
    this.storeCount = 3,
    this.userName = 'Sari Ayu',
    this.onNavigate,
    this.onSwitchStore,
  });

  final List<Product> initialProducts;
  final String? initialSelectedId;
  final String storeName;
  final int storeCount;
  final String userName;
  final ValueChanged<AdminDestination>? onNavigate;
  final VoidCallback? onSwitchStore;

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  late List<Product> _products = widget.initialProducts;
  late String? _selectedId = widget.initialSelectedId;
  String _query = '';
  String _category = productCategories.first;
  bool _lowOnly = false;

  List<Product> get _visible {
    final q = _query.trim().toLowerCase();
    return _products.where((p) {
      final inCategory =
          _category == productCategories.first || p.category == _category;
      final matches =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.sku.toLowerCase().contains(q) ||
          (p.barcode?.contains(q) ?? false);
      return inCategory && matches && (!_lowOnly || p.isLowStock);
    }).toList();
  }

  Product? get _selected {
    for (final p in _products) {
      if (p.id == _selectedId) return p;
    }
    return null;
  }

  void _save(Product updated) {
    setState(() {
      _products = [for (final p in _products) p.id == updated.id ? updated : p];
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${updated.name} disimpan')));
  }

  void _navigate(AdminDestination d) {
    final handler = widget.onNavigate;
    if (handler != null) {
      handler(d);
    } else if (d != AdminDestination.produk) {
      showComingSoon(context, adminSidebarItems[d.index].label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final lowCount = _products.where((p) => p.isLowStock).length;

    return TabletOnly(
      child: Scaffold(
        body: Row(
          children: [
            AdminSidebar(
              current: AdminDestination.produk,
              onNavigate: _navigate,
              storeName: widget.storeName,
              storeCount: widget.storeCount,
              userName: widget.userName,
              onSwitchStore: widget.onSwitchStore,
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
                          _Header(count: _products.length),
                          ProductFilters(
                            onQuery: (q) => setState(() => _query = q),
                            category: _category,
                            onCategory: (c) => setState(() => _category = c),
                            lowOnly: _lowOnly,
                            lowCount: lowCount,
                            onToggleLow: () =>
                                setState(() => _lowOnly = !_lowOnly),
                          ),
                          Expanded(
                            child: ProductTable(
                              products: _visible,
                              selectedId: _selectedId,
                              onSelect: (p) =>
                                  setState(() => _selectedId = p.id),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected != null)
                      SizedBox(
                        width: AppLayout.editPanel,
                        child: ProductEditPanel(
                          key: ValueKey(selected.id),
                          product: selected,
                          onSave: _save,
                          onClose: () => setState(() => _selectedId = null),
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

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: AppSpacing.sm,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk', style: context.text.headlineMedium),
            Text(
              '$count produk · ${productCategories.length - 1} kategori',
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          spacing: AppSpacing.xs,
          children: [
            AppButton(
              label: 'Kategori',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () => showComingSoon(context, 'Kelola kategori'),
            ),
            AppButton(
              label: 'Tambah produk',
              icon: AppIcons.plus,
              size: AppButtonSize.small,
              expand: false,
              onPressed: () => showComingSoon(context, 'Tambah produk'),
            ),
          ],
        ),
      ],
    );
  }
}
