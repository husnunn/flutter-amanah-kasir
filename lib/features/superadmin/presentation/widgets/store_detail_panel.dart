import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/managed_user.dart';
import '../../data/store_record.dart';
import '../../state/superadmin_providers.dart';
import 'detail_parts.dart';

/// Panel detail toko (340 dp): sakelar aktif, info, pengguna toko, aksi.
class StoreDetailPanel extends ConsumerWidget {
  const StoreDetailPanel({
    super.key,
    required this.store,
    required this.users,
    required this.onToggleActive,
    required this.onEdit,
    required this.onAddUser,
  });

  final StoreRecord store;

  /// Pengguna yang terikat ke toko ini (admin dulu).
  final List<ManagedUser> users;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onAddUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.text;
    final colors = context.colors;
    final muted = text.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final created = store.createdAt;
    final transactions = ref
        .watch(monthlyTransactionsProvider(store.id))
        .when(data: formatNumber, loading: () => '...', error: (_, _) => '-');

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
                      created == null
                          ? 'Kode ${store.code}'
                          : 'Dibuat ${formatDateShort(created)}',
                      style: muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ActiveSwitchRow(
            label: 'Toko aktif',
            value: store.isActive,
            onChanged: onToggleActive,
          ),
          DetailInfoRow(
            label: 'Alamat',
            value: store.address.isEmpty ? '-' : store.address,
          ),
          DetailInfoRow(
            label: 'Telepon',
            value: store.phone.isEmpty ? '-' : store.phone,
          ),
          DetailInfoRow(
            label: 'Scan barcode',
            value: store.scanEnabled ? 'Aktif' : 'Nonaktif',
          ),
          DetailInfoRow(label: 'Transaksi bulan ini', value: transactions),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengguna di toko ini',
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text('${users.length} orang', style: muted),
            ],
          ),
          Expanded(
            child: ListView.separated(
              itemCount: users.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => i == users.length
                  ? DashedAddButton(label: 'Tambah pengguna', onTap: onAddUser)
                  : PanelUserRow(user: users[i]),
            ),
          ),
          AppButton(
            label: 'Edit data toko',
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
