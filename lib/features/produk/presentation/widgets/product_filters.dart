import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/product.dart';

/// Baris filter daftar produk: pencarian, kategori, dan tombol stok menipis.
class ProductFilters extends StatelessWidget {
  const ProductFilters({
    super.key,
    required this.onQuery,
    required this.category,
    required this.onCategory,
    required this.lowOnly,
    required this.lowCount,
    required this.onToggleLow,
  });

  final ValueChanged<String> onQuery;
  final String category;
  final ValueChanged<String> onCategory;
  final bool lowOnly;
  final int lowCount;
  final VoidCallback onToggleLow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.app;
    final text = context.text;
    final allLabel = productCategories.first;

    final search = AppTextField(
      hint: 'Cari nama, SKU, atau barcode',
      leading: AppIcons.search,
      onChanged: onQuery,
    );
    final menus = <Widget>[
      PopupMenuButton<String>(
        tooltip: 'Filter kategori',
        onSelected: onCategory,
        itemBuilder: (_) => [
          for (final c in productCategories)
            PopupMenuItem(
              value: c,
              child: Text(c == allLabel ? 'Semua kategori' : c),
            ),
        ],
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.outline),
          ),
          child: SizedBox(
            height: AppSize.field,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  Text(
                    category == allLabel ? 'Semua kategori' : category,
                    style: text.bodySmall?.copyWith(
                      color: app.ink2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const AppIcon(AppIcons.chevronDown, size: AppSize.iconSm),
                ],
              ),
            ),
          ),
        ),
      ),
      Semantics(
        button: true,
        toggled: lowOnly,
        child: Material(
          color: app.warningSoft,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdAll,
            side: BorderSide(
              color: app.warningBorder,
              width: lowOnly ? AppSize.borderThick : AppSize.borderThin,
            ),
          ),
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onToggleLow,
            child: SizedBox(
              height: AppSize.field,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: Text(
                    'Stok menipis · $lowCount',
                    style: text.bodySmall?.copyWith(
                      color: app.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppLayout.filtersOneRow) {
          return Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(child: search),
              ...menus,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            search,
            Row(spacing: AppSpacing.sm, children: menus),
          ],
        );
      },
    );
  }
}
