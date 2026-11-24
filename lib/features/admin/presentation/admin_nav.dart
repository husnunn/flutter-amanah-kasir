import 'package:material_ui/material_ui.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';

/// Tujuan menu admin (urutan sama dengan [adminSidebarItems]).
enum AdminDestination {
  dashboard,
  kasir,
  produk,
  pengeluaran,
  laporan,
  riwayat,
  kasirShift,
  pengaturan,
}

const adminSidebarItems = <NavItem>[
  NavItem(icon: AppIcons.dashboard, label: 'Dashboard'),
  NavItem(icon: AppIcons.shoppingBag, label: 'Kasir'),
  NavItem(icon: AppIcons.package, label: 'Produk'),
  NavItem(icon: AppIcons.wallet, label: 'Pengeluaran'),
  NavItem(icon: AppIcons.barChart, label: 'Laporan'),
  NavItem(icon: AppIcons.receipt, label: 'Riwayat transaksi'),
  NavItem(icon: AppIcons.users, label: 'Kasir & shift'),
  NavItem(icon: AppIcons.sliders, label: 'Pengaturan toko'),
];

const adminPhoneNav = <NavItem>[
  NavItem(icon: AppIcons.dashboard, label: 'Beranda'),
  NavItem(icon: AppIcons.shoppingBag, label: 'Kasir'),
  NavItem(icon: AppIcons.package, label: 'Produk'),
  NavItem(icon: AppIcons.barChart, label: 'Laporan'),
  NavItem(icon: AppIcons.more, label: 'Lainnya'),
];

/// Tujuan untuk tiap item [adminPhoneNav]; null = belum ada layarnya.
const adminPhoneDestinations = <AdminDestination?>[
  AdminDestination.dashboard,
  AdminDestination.kasir,
  AdminDestination.produk,
  AdminDestination.laporan,
  null,
];

/// Sidebar admin 240 dp: pemilih toko aktif di atas, menu, profil di bawah.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.current,
    required this.onNavigate,
    this.storeName = 'Toko Berkah Jaya',
    this.storeCount = 3,
    this.userName = 'Sari Ayu',
    this.onSwitchStore,
    this.onLogout,
  });

  final AdminDestination current;
  final ValueChanged<AdminDestination> onNavigate;
  final String storeName;
  final int storeCount;
  final String userName;
  final VoidCallback? onSwitchStore;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return AppSidebar(
      items: adminSidebarItems,
      selectedIndex: current.index,
      onSelected: (i) => onNavigate(AdminDestination.values[i]),
      header: SidebarStorePicker(
        storeName: storeName,
        storeCount: storeCount,
        onTap: onSwitchStore,
      ),
      userName: userName,
      userRole: 'Admin',
      userInitials: initialsOf(userName),
      onLogout: onLogout,
    );
  }
}
