import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_icon.dart';

/// Stepper jumlah: tombol − abu-abu, angka tebal, tombol + hijau muda.
class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
    this.itemName,
  });

  final int qty;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  /// Dipakai untuk label aksesibilitas, mis. "Kurangi Kopi Sachet".
  final String? itemName;

  static const double _button = 32;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final suffix = itemName == null ? '' : ' $itemName';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepButton(
              label: 'Kurangi$suffix',
              icon: AppIcons.minus,
              background: colors.surfaceContainer,
              foreground: context.app.ink2,
              onTap: onDecrement,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: AppSpacing.xxl - 4),
              child: Text(
                '$qty',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _StepButton(
              label: 'Tambah$suffix',
              icon: AppIcons.plus,
              background: colors.primaryContainer,
              foreground: colors.primary,
              onTap: onIncrement,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final AppIconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: onTap,
          child: SizedBox.square(
            dimension: QtyStepper._button,
            child: Center(
              child: AppIcon(
                icon,
                size: AppSize.iconXs,
                color: foreground,
                strokeWidth: 2.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
