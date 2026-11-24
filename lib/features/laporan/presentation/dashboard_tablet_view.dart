import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../admin/presentation/admin_nav.dart';
import '../data/dashboard_data.dart';
import 'widgets/payment_split_bar.dart';
import 'widgets/revenue_bar_chart.dart';
import 'widgets/side_cards.dart';

/// Dashboard tablet: sidebar 240 | header + 4 kartu angka + grafik + kolom kanan 320.
class DashboardTabletView extends StatelessWidget {
  const DashboardTabletView({
    super.key,
    required this.data,
    required this.period,
    required this.onPeriod,
    required this.storeName,
    required this.storeCount,
    required this.userName,
    required this.lowStock,
    required this.onNavigate,
    this.onSwitchStore,
    this.onLogout,
  });

  final DashboardData data;
  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onPeriod;
  final String storeName;
  final int storeCount;
  final String userName;
  final List<LowStockItem> lowStock;
  final ValueChanged<AdminDestination> onNavigate;
  final VoidCallback? onSwitchStore;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(
            current: AdminDestination.dashboard,
            onNavigate: onNavigate,
            storeName: storeName,
            storeCount: storeCount,
            userName: userName,
            onSwitchStore: onSwitchStore,
            onLogout: onLogout,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: MinHeightScroll(
                minHeight: AppLayout.dashboardMinHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.lg,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dashboard', style: text.headlineMedium),
                            Text(
                              '${data.rangeLabel} · $storeName',
                              style: text.bodySmall?.copyWith(
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SegmentedTabs(
                          labels: [
                            for (final p in ReportPeriod.values) p.label,
                          ],
                          selectedIndex: period.index,
                          onChanged: (i) => onPeriod(ReportPeriod.values[i]),
                        ),
                      ],
                    ),
                    _StatRow(data: data),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.md,
                        children: [
                          Expanded(
                            child: _ChartCard(data: data, period: period),
                          ),
                          SizedBox(
                            width: AppLayout.sideColumn,
                            child: Column(
                              spacing: AppSpacing.md,
                              children: [
                                TopProductsCard(products: data.topProducts),
                                Expanded(child: LowStockCard(items: lowStock)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Expanded(
          child: StatCard(
            label: 'Saldo kotor',
            value: formatRupiah(data.grossSales),
            caption: '${formatNumber(data.txCount)} transaksi',
          ),
        ),
        Expanded(
          child: StatCard(
            label: 'Laba kotor',
            value: formatRupiah(data.grossProfit),
            caption: 'Penjualan − HPP',
          ),
        ),
        Expanded(
          child: StatCard(
            label: 'Pengeluaran',
            value: formatRupiah(data.expense),
            caption: '${data.expenseCount} catatan',
            valueColor: context.colors.error,
          ),
        ),
        Expanded(
          child: StatCard(
            label: 'Saldo bersih',
            value: formatRupiah(data.netBalance),
            caption: 'Laba kotor − pengeluaran',
            emphasized: true,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.data, required this.period});

  final DashboardData data;
  final ReportPeriod period;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(period.chartTitle, style: text.titleSmall),
              Text.rich(
                TextSpan(
                  text: 'Hari ini: ',
                  children: [
                    TextSpan(
                      text: formatRupiah(data.todaySales),
                      style: text.labelMedium?.copyWith(
                        color: context.colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: text.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: RevenueBarChart(spec: data.chart)),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          PaymentSplitBar(shares: data.paymentSplit),
        ],
      ),
    );
  }
}
