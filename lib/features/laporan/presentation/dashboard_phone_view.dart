import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/coming_soon.dart';
import '../../../core/widgets/widgets.dart';
import '../../admin/presentation/admin_nav.dart';
import '../data/dashboard_data.dart';
import 'widgets/phone_widgets.dart';
import 'widgets/revenue_bar_chart.dart';

/// Dashboard HP: pemilih toko + avatar, periode, kartu saldo hijau, grafik,
/// peringatan stok, aksi cepat, navigasi bawah.
class DashboardPhoneView extends StatelessWidget {
  const DashboardPhoneView({
    super.key,
    required this.data,
    required this.period,
    required this.onPeriod,
    required this.storeName,
    required this.lowStock,
    required this.onNavigate,
    this.onSwitchStore,
  });

  final DashboardData data;
  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onPeriod;
  final String storeName;
  final List<LowStockItem> lowStock;
  final ValueChanged<AdminDestination> onNavigate;
  final VoidCallback? onSwitchStore;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPhone,
                  AppSpacing.lg,
                  AppSpacing.screenPhone,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: StoreChipButton(
                            storeName: storeName,
                            onTap: onSwitchStore,
                          ),
                        ),
                        const InitialAvatar(
                          'SA',
                          avatarStyle: AvatarStyle.outlined,
                        ),
                      ],
                    ),
                    SegmentedTabs(
                      expand: true,
                      labels: [for (final p in ReportPeriod.values) p.label],
                      selectedIndex: period.index,
                      onChanged: (i) => onPeriod(ReportPeriod.values[i]),
                    ),
                    BalanceHeroCard(data: data),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.md,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(period.chartTitle, style: text.titleSmall),
                              Text(
                                'dalam ribu Rp',
                                style: text.labelMedium?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: AppLayout.phoneChartHeight,
                            child: RevenueBarChart(
                              spec: data.chart,
                              compact: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LowStockBanner(
                      items: lowStock,
                      onTap: () =>
                          showComingSoon(context, 'Daftar stok menipis'),
                    ),
                    QuickActions(
                      onAddProduct: () => onNavigate(AdminDestination.produk),
                      onExpense: () => onNavigate(AdminDestination.pengeluaran),
                      onReport: () => onNavigate(AdminDestination.laporan),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppBottomNav(
            items: adminPhoneNav,
            currentIndex: 0,
            onTap: (i) {
              final destination = adminPhoneDestinations[i];
              if (destination == null) {
                showComingSoon(context, 'Menu lainnya');
              } else {
                onNavigate(destination);
              }
            },
          ),
        ],
      ),
    );
  }
}
