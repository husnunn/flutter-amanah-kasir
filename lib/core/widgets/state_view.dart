import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_button.dart';
import 'app_icon.dart';

/// Tampilan kosong / informasi: ikon dalam lingkaran, judul, penjelasan, aksi.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final AppIconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.sm,
          children: [
            CircleAvatar(
              radius: AppSpacing.xxl,
              backgroundColor: colors.primaryContainer,
              child: AppIcon(
                icon,
                size: AppSize.iconHero,
                color: colors.primary,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleMedium,
            ),
            if (message != null)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            if (actionLabel != null && onAction != null)
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.medium,
                expand: false,
              ),
          ],
        ),
      ),
    );
  }
}
