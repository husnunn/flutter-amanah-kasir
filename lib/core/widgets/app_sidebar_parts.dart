import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';
import 'app_icon.dart';
import 'nav_item.dart';

class SidebarRoleBadge extends StatelessWidget {
  const SidebarRoleBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.xs, 0, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.all(Radius.circular(6)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            child: Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: context.app.accentMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.item,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final background = !selected
        ? Colors.transparent
        : dark
        ? colors.onSecondary.withValues(alpha: 0.1)
        : colors.primaryContainer;
    final foreground = selected
        ? (dark ? colors.onSecondary : colors.primary)
        : (dark ? context.app.borderInput : context.app.ink2);

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: background,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: onTap,
          child: SizedBox(
            height: AppSize.fieldDense,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  AppIcon(item.icon, color: foreground),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
