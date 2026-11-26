import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/store_record.dart';

/// Panel detail toko (340 dp): sakelar aktif, info, daftar pengguna, aksi.
class StoreDetailPanel extends StatelessWidget {
  const StoreDetailPanel({
    super.key,
    required this.store,
    required this.onToggleActive,
    required this.onAddUser,
    this.busy = false,
  });

  final StoreRecord store;

  /// Null = sakelar tidak bisa diubah.
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback onAddUser;

  /// Status sedang diubah; sakelar dikunci sampai selesai.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final colors = context.colors;
    final muted = text.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            spacing: AppSpacing.sm,
            children: [
              InitialBlock(
                label: store.code,
                tone: ToneName.green,
                width: AppSize.touch,
                height: AppSize.touch,
                radius: AppRadius.mdAll,
                style: text.bodySmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        if (store.area.isNotEmpty) store.area,
                        if (store.createdLabel != null)
                          'dibuat ${store.createdLabel}',
                      ].join(' · '),
                      style: muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          DecoratedBox(
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
                    'Toko aktif',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: store.active,
                    onChanged: busy ? null : onToggleActive,
                  ),
                ],
              ),
            ),
          ),
          _InfoRow(
            label: 'Scan barcode',
            value: store.scanEnabled ? 'Aktif' : 'Nonaktif',
          ),
          _InfoRow(
            label: 'Transaksi bulan ini',
            value: store.transactionsThisMonth == null
                ? '—'
                : formatNumber(store.transactionsThisMonth!),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengguna di toko ini',
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('${store.users.length} orang', style: muted),
            ],
          ),
          Expanded(
            child: ListView.separated(
              itemCount: store.users.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                if (i == store.users.length) {
                  return DashedBorderBox(
                    radius: AppRadius.mdAll,
                    background: colors.surface,
                    onTap: onAddUser,
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
                            'Tambah pengguna',
                            style: text.bodyMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return _UserRow(user: store.users[i]);
              },
            ),
          ),
          AppButton(
            label: 'Edit data toko',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
            onPressed: () => showComingSoon(context, 'Edit data toko'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: text.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});

  final StoreUser user;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
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
                user.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        StatusBadge(
          user.role.label,
          tone: user.role == UserRole.admin
              ? BadgeTone.info
              : BadgeTone.neutral,
          rounded: true,
        ),
      ],
    );
  }
}
