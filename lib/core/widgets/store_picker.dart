import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'app_icon.dart';

/// Pemilih toko aktif di sidebar admin: label "Toko aktif · N toko", nama toko
/// tebal, ikon panah atas-bawah.
class SidebarStorePicker extends StatelessWidget {
  const SidebarStorePicker({
    super.key,
    required this.storeName,
    required this.storeCount,
    this.onTap,
  });

  final String storeName;
  final int storeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: 'Ganti toko aktif, $storeName',
      child: Material(
        color: context.app.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: colors.outline),
        ),
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Toko aktif · $storeCount toko',
                        style: context.text.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const AppIcon(AppIcons.chevronsUpDown, size: AppSize.iconMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol toko aktif untuk header HP: ikon toko hijau, nama, panah bawah.
class StoreChipButton extends StatelessWidget {
  const StoreChipButton({super.key, required this.storeName, this.onTap});

  final String storeName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: 'Pilih toko, $storeName',
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: BorderSide(color: colors.outline),
        ),
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: SizedBox(
            height: AppSize.touch,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  AppIcon(
                    AppIcons.store,
                    size: AppSize.iconMd,
                    color: colors.primary,
                  ),
                  Flexible(
                    child: Text(
                      storeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const AppIcon(AppIcons.chevronDown, size: AppSize.iconSm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
