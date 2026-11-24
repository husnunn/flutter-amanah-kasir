import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_icon.dart';
import 'initial_avatar.dart';
import 'logo_mark.dart';
import 'app_sidebar_parts.dart';
import 'nav_item.dart';

/// Sidebar 240 dp: logo, [header] (mis. pemilih toko), menu, profil.
/// [dark] = varian gelap untuk superadmin; [badgeLabel] = lencana di bawah logo.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.userName,
    required this.userRole,
    required this.userInitials,
    this.header,
    this.badgeLabel,
    this.dark = false,
    this.onLogout,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String userName;
  final String userRole;
  final String userInitials;
  final Widget? header;
  final String? badgeLabel;
  final bool dark;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.app;
    final divider = dark
        ? colors.onSecondary.withValues(alpha: 0.12)
        : colors.outlineVariant;
    final nameColor = dark ? colors.onSecondary : colors.onSurface;
    final mutedColor = dark ? app.borderInput : colors.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? colors.secondary : colors.surface,
        border: dark ? null : Border(right: BorderSide(color: colors.outline)),
      ),
      child: SizedBox(
        width: AppLayout.sidebar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Row(
                  spacing: AppSpacing.sm,
                  children: [
                    const LogoMark(size: LogoSize.sm),
                    Text(
                      'Kasir',
                      style: context.text.titleMedium?.copyWith(
                        color: nameColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeLabel != null) SidebarRoleBadge(label: badgeLabel!),
              const SizedBox(height: AppSpacing.md),
              if (header != null) ...[
                header!,
                const SizedBox(height: AppSpacing.sm),
              ],
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                        child: SidebarItem(
                          item: items[i],
                          selected: i == selectedIndex,
                          dark: dark,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(color: divider),
              const SizedBox(height: AppSpacing.sm),
              Row(
                spacing: AppSpacing.sm,
                children: [
                  InitialAvatar(
                    userInitials,
                    size: AppSpacing.xxl + 4,
                    avatarStyle: dark ? AvatarStyle.dark : AvatarStyle.soft,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(
                            color: nameColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          userRole,
                          style: context.text.labelMedium?.copyWith(
                            color: mutedColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onLogout != null)
                    IconButton(
                      tooltip: 'Keluar',
                      onPressed: onLogout,
                      color: mutedColor,
                      icon: const AppIcon(
                        AppIcons.logOut,
                        size: AppSize.iconMd,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
