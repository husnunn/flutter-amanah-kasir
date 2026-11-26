import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/data/app_role.dart';
import '../../data/managed_user.dart';

/// Baris "label ... nilai" di panel detail.
class DetailInfoRow extends StatelessWidget {
  const DetailInfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Kotak abu-abu berisi judul dan sakelar aktif/nonaktif.
class ActiveSwitchRow extends StatelessWidget {
  const ActiveSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.app.surfaceAlt,
        borderRadius: AppRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Tombol bergaris putus-putus hijau, mis. "Tambah pengguna".
class DashedAddButton extends StatelessWidget {
  const DashedAddButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashedBorderBox(
      radius: AppRadius.mdAll,
      background: colors.surface,
      onTap: onTap,
      child: SizedBox(
        height: AppSize.buttonSmall,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppSpacing.xs,
          children: [
            AppIcon(
              AppIcons.plus,
              size: AppSize.iconSm,
              color: colors.primary,
              strokeWidth: 2.2,
            ),
            Text(
              label,
              style: context.text.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lencana peran: Admin (biru), Kasir (abu-abu), Superadmin (hijau).
class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});

  final AppRole role;

  @override
  Widget build(BuildContext context) => StatusBadge(
    role.label,
    tone: switch (role) {
      AppRole.superadmin => BadgeTone.success,
      AppRole.admin => BadgeTone.info,
      AppRole.kasir => BadgeTone.neutral,
    },
    rounded: true,
  );
}

/// Baris pengguna di panel detail toko: avatar, nama, email, peran.
class PanelUserRow extends StatelessWidget {
  const PanelUserRow({super.key, required this.user});

  final ManagedUser user;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final muted = text.labelMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    return Row(
      spacing: AppSpacing.sm,
      children: [
        InitialAvatar(user.initials, size: AppSpacing.xxl + 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                user.isActive ? user.email : 'Nonaktif · ${user.email}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ],
          ),
        ),
        RoleBadge(user.role),
      ],
    );
  }
}
