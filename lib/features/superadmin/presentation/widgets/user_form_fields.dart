import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/data/app_role.dart';
import '../../data/store_record.dart';

/// "TK01 - Toko Berkah Jaya", ditambah "(nonaktif)" bila toko dimatikan.
String storeOptionLabel(StoreRecord store) =>
    '${store.code} - ${store.name}${store.isActive ? '' : ' (nonaktif)'}';

/// Daftar centang toko untuk admin (boleh banyak toko).
class StoreCheckList extends StatelessWidget {
  const StoreCheckList({
    super.key,
    required this.stores,
    required this.selected,
    required this.onToggle,
    this.errorText,
  });

  final List<StoreRecord> stores;
  final Set<String> selected;
  final void Function(String storeId, bool checked) onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        const FieldLabel('Toko yang dikelola *'),
        if (hasError)
          Text(
            errorText!,
            style: context.text.bodySmall?.copyWith(color: colors.error),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: hasError ? colors.error : context.app.borderInput,
              width: hasError ? AppSize.borderMedium : AppSize.borderThin,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Column(
              children: [
                for (final store in stores)
                  CheckboxListTile(
                    value: selected.contains(store.id),
                    onChanged: (v) => onToggle(store.id, v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: Text(
                      storeOptionLabel(store),
                      style: context.text.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Isian toko sesuai peran: superadmin tanpa toko, kasir satu toko (dropdown),
/// admin satu atau lebih (daftar centang).
class UserStoreFields extends StatelessWidget {
  const UserStoreFields({
    super.key,
    required this.role,
    required this.stores,
    required this.kasirStore,
    required this.adminStores,
    required this.onKasirChanged,
    required this.onAdminToggle,
    this.errorText,
  });

  final AppRole role;
  final List<StoreRecord> stores;
  final String? kasirStore;
  final Set<String> adminStores;
  final ValueChanged<String?> onKasirChanged;
  final void Function(String storeId, bool checked) onAdminToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return switch (role) {
      AppRole.superadmin => Text(
        'Superadmin mengelola semua toko.',
        style: context.text.labelMedium?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
      AppRole.kasir => AppDropdownField<String?>(
        label: 'Toko *',
        value: stores.any((s) => s.id == kasirStore) ? kasirStore : null,
        items: [null, for (final s in stores) s.id],
        itemLabel: (id) => id == null
            ? 'Pilih toko'
            : storeOptionLabel(stores.firstWhere((s) => s.id == id)),
        errorText: errorText,
        onChanged: onKasirChanged,
      ),
      AppRole.admin => StoreCheckList(
        stores: stores,
        selected: adminStores,
        errorText: errorText,
        onToggle: onAdminToggle,
      ),
    };
  }
}
