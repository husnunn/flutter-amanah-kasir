import 'package:material_ui/material_ui.dart';

import '../../../core/utils/coming_soon.dart';
import '../../../core/widgets/widgets.dart';
import '../../admin/presentation/admin_nav.dart';
import '../data/dashboard_data.dart';
import '../data/sample_dashboards.dart';
import 'dashboard_phone_view.dart';
import 'dashboard_tablet_view.dart';

/// Dashboard admin: saldo kotor/bersih, grafik pendapatan, metode bayar, produk
/// terlaris, stok menipis. Tablet = sidebar + panel; HP = kartu saldo + grafik 7 hari.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.storeName = 'Toko Berkah Jaya',
    this.storeCount = 3,
    this.userName = 'Sari Ayu',
    this.initialPeriod,
    this.onNavigate,
    this.onSwitchStore,
    this.onLogout,
  });

  final String storeName;
  final int storeCount;
  final String userName;

  /// Periode awal; null = Bulan di tablet, Minggu di HP (seperti desain).
  final ReportPeriod? initialPeriod;
  final ValueChanged<AdminDestination>? onNavigate;
  final VoidCallback? onSwitchStore;
  final VoidCallback? onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ReportPeriod? _period;

  void _navigate(AdminDestination destination) {
    final handler = widget.onNavigate;
    if (handler != null) {
      handler(destination);
    } else if (destination != AdminDestination.dashboard) {
      showComingSoon(context, adminSidebarItems[destination.index].label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tablet: (_) {
        final period = _period ?? widget.initialPeriod ?? ReportPeriod.bulan;
        return DashboardTabletView(
          data: sampleDashboards[period]!,
          period: period,
          onPeriod: (p) => setState(() => _period = p),
          storeName: widget.storeName,
          storeCount: widget.storeCount,
          userName: widget.userName,
          lowStock: sampleLowStock,
          onNavigate: _navigate,
          onSwitchStore: widget.onSwitchStore,
          onLogout: widget.onLogout,
        );
      },
      phone: (_) {
        final period = _period ?? widget.initialPeriod ?? ReportPeriod.minggu;
        return DashboardPhoneView(
          data: sampleDashboards[period]!,
          period: period,
          onPeriod: (p) => setState(() => _period = p),
          storeName: widget.storeName,
          userName: widget.userName,
          lowStock: sampleLowStock,
          onNavigate: _navigate,
          onSwitchStore: widget.onSwitchStore,
        );
      },
    );
  }
}
