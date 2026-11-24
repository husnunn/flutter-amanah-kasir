import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_icon.dart';
import 'initial_avatar.dart';
import 'logo_mark.dart';
import 'nav_item.dart';

/// Rail navigasi kiri (88 dp) untuk layar kasir tablet: logo, menu, avatar, keluar.
class AppNavRail extends StatelessWidget {
  const AppNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.userInitials,
    this.onLogout,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String userInitials;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.outline)),
      ),
      child: SizedBox(
        width: AppLayout.rail,
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),
            const LogoMark(),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                child: _RailItem(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              ),
            const Spacer(),
            InitialAvatar(userInitials),
            IconButton(
              tooltip: 'Keluar',
              onPressed: onLogout,
              color: colors.onSurfaceVariant,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(AppSize.touch),
              ),
              icon: const AppIcon(AppIcons.logOut),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.primary : colors.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: ExcludeSemantics(
        child: Material(
          color: selected ? colors.primaryContainer : Colors.transparent,
          borderRadius: AppRadius.mdAll,
          child: InkWell(
            borderRadius: AppRadius.mdAll,
            onTap: onTap,
            child: SizedBox(
              width: AppLayout.rail - AppSpacing.lg,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  spacing: AppSpacing.xxs,
                  children: [
                    AppIcon(item.icon, size: AppSize.iconLg, color: foreground),
                    Text(
                      item.label,
                      style: context.text.labelSmall?.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
