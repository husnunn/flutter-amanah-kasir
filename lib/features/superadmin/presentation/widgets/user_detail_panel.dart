import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/data/app_role.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import 'detail_parts.dart';

/// Panel detail pengguna (340 dp): identitas, peran, toko, status, aksi.
/// Akun yang sedang masuk ([isSelf]) tidak bisa dinonaktifkan.
class UserDetailPanel extends StatelessWidget {
  const UserDetailPanel({
    super.key,
    required this.user,
    required this.stores,
    required this.isSelf,
    required this.onEdit,
    required this.onSendReset,
    required this.onToggleActive,
  });

  final ManagedUser user;
  final List<StoreRecord> stores;
  final bool isSelf;
  final VoidCallback onEdit;
  final VoidCallback onSendReset;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final muted = text.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final assigned = [
      for (final id in user.storeIds)
        ?stores.where((s) => s.id == id).firstOrNull,
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              InitialAvatar(user.initials, size: AppSize.touch),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSelf ? '${user.name} (Anda)' : user.name,
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user.email,
                      style: muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: AppSpacing.xs,
            children: [
              RoleBadge(user.role),
              StatusBadge(
                user.isActive ? 'Aktif' : 'Nonaktif',
                tone: user.isActive ? BadgeTone.success : BadgeTone.neutral,
              ),
            ],
          ),
          const Divider(),
          Text(
            user.role == AppRole.superadmin ? 'Akses' : 'Toko',
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: ListView(
              children: [
                if (user.role == AppRole.superadmin)
                  Text('Semua toko dan pengguna.', style: muted)
                else if (assigned.isEmpty)
                  Text('Belum terikat ke toko.', style: muted)
                else
                  for (final store in assigned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        spacing: AppSpacing.sm,
                        children: [
                          InitialBlock(
                            label: store.code,
                            tone: ToneName.slate,
                            width: AppSize.chip,
                            height: AppSize.chip,
                            style: text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              store.isActive
                                  ? store.name
                                  : '${store.name} (nonaktif)',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          AppButton(
            label: 'Edit pengguna',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
            onPressed: onEdit,
          ),
          AppButton(
            label: 'Kirim tautan reset password',
            icon: AppIcons.mail,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
            onPressed: onSendReset,
          ),
          if (isSelf)
            Text(
              'Akun Anda sendiri tidak bisa dinonaktifkan.',
              textAlign: TextAlign.center,
              style: muted,
            )
          else if (user.isActive)
            AppButton(
              label: 'Nonaktifkan pengguna',
              variant: AppButtonVariant.destructive,
              size: AppButtonSize.medium,
              onPressed: onToggleActive,
            )
          else
            AppButton(
              label: 'Aktifkan pengguna',
              size: AppButtonSize.medium,
              onPressed: onToggleActive,
            ),
        ],
      ),
    );
  }
}
