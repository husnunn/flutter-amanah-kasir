import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/utils/coming_soon.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../state/superadmin_providers.dart';
import 'widgets/stores_section.dart';
import 'widgets/users_section.dart';

const _superadminNav = <NavItem>[
  NavItem(icon: AppIcons.dashboard, label: 'Ringkasan'),
  NavItem(icon: AppIcons.store, label: 'Toko'),
  NavItem(icon: AppIcons.users, label: 'Pengguna'),
  NavItem(icon: AppIcons.sliders, label: 'Pengaturan aplikasi'),
];

const _storesIndex = 1;
const _usersIndex = 2;

/// Superadmin - Kelola toko dan pengguna (tablet): sidebar gelap berpindah
/// antara bagian Toko dan Pengguna. Data dari [superadminRepositoryProvider].
///
/// [currentUid] adalah akun yang sedang masuk; akun itu diberi tanda "Anda" dan
/// tidak bisa dinonaktifkan atau diubah perannya.
class TokoPenggunaScreen extends ConsumerWidget {
  const TokoPenggunaScreen({
    super.key,
    required this.currentUid,
    this.userName = 'Pemilik aplikasi',
    this.onLogout,
  });

  final String currentUid;
  final String userName;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(superadminSectionProvider);
    final selectedIndex = section == SuperadminSection.stores
        ? _storesIndex
        : _usersIndex;

    void select(int index) {
      switch (index) {
        case _storesIndex:
          ref
              .read(superadminSectionProvider.notifier)
              .set(SuperadminSection.stores);
        case _usersIndex:
          ref
              .read(superadminSectionProvider.notifier)
              .set(SuperadminSection.users);
        default:
          showComingSoon(context, _superadminNav[index].label);
      }
    }

    return TabletOnly(
      child: Scaffold(
        body: Row(
          children: [
            AppSidebar(
              dark: true,
              badgeLabel: 'SUPERADMIN',
              items: _superadminNav,
              selectedIndex: selectedIndex,
              onSelected: select,
              userName: userName,
              userRole: 'Superadmin',
              userInitials: initialsOf(userName),
              onLogout: onLogout,
            ),
            Expanded(
              child: switch (section) {
                SuperadminSection.stores => StoresSection(
                  currentUid: currentUid,
                ),
                SuperadminSection.users => UsersSection(currentUid: currentUid),
              },
            ),
          ],
        ),
      ),
    );
  }
}
