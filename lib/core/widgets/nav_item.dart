import '../icons/app_icons.dart';

/// Satu tujuan navigasi (ikon + label) untuk rail, sidebar, dan bottom nav.
class NavItem {
  const NavItem({required this.icon, required this.label});

  final AppIconData icon;
  final String label;
}
