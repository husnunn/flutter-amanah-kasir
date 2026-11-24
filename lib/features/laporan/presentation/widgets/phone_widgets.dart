import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/dashboard_data.dart';

/// Kartu saldo hijau di dashboard HP: saldo bersih besar, lalu saldo kotor dan
/// pengeluaran dalam dua kolom.
class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final muted = context.app.onAccentMuted;
    Widget cell(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xxs,
        children: [
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: text.titleSmall?.copyWith(color: colors.onPrimary),
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.xxlAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.heroCaption,
              style: text.bodySmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              formatRupiah(data.netBalance),
              style: text.displayLarge?.copyWith(color: colors.onPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.onPrimary.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  spacing: AppSpacing.sm,
                  children: [
                    cell('Saldo kotor', formatRupiah(data.grossSales)),
                    cell('Pengeluaran', formatRupiah(data.expense)),
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

/// Banner amber peringatan stok hampir habis (dashboard HP).
class LowStockBanner extends StatelessWidget {
  const LowStockBanner({super.key, required this.items, this.onTap});

  final List<LowStockItem> items;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final app = context.app;
    final text = context.text;
    return Material(
      color: app.warningSoft,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: app.warningBorder),
      ),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              AppIcon(
                AppIcons.alertTriangle,
                size: AppSize.iconLg,
                color: app.warning,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${items.length} produk hampir habis',
                      style: text.bodyMedium?.copyWith(
                        color: app.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      items
                          .map(
                            (i) => i.name.replaceAll(RegExp(r'\s+\d.*$'), ''),
                          )
                          .join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium?.copyWith(color: app.warning),
                    ),
                  ],
                ),
              ),
              AppIcon(
                AppIcons.chevronRight,
                size: AppSize.iconSm,
                color: app.warning,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiga aksi cepat dashboard HP: tambah produk, pengeluaran, laporan.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onAddProduct,
    required this.onExpense,
    required this.onReport,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onExpense;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: _Action(
            icon: AppIcons.plus,
            label: 'Tambah produk',
            onTap: onAddProduct,
          ),
        ),
        Expanded(
          child: _Action(
            icon: AppIcons.wallet,
            label: 'Pengeluaran',
            onTap: onExpense,
          ),
        ),
        Expanded(
          child: _Action(
            icon: AppIcons.receipt,
            label: 'Laporan',
            onTap: onReport,
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final AppIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      radius: AppRadius.lgAll,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        spacing: AppSpacing.xs,
        children: [
          AppIcon(icon, size: AppSize.iconLg, color: context.colors.primary),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelMedium,
          ),
        ],
      ),
    );
  }
}
