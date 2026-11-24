import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Kolom cari produk. Di HP latarnya abu-abu dan tombol scan ada di dalam
/// ([onScan]); di tablet tombol scan dibuat terpisah oleh pemanggil.
class ProductSearchField extends StatelessWidget {
  const ProductSearchField({
    super.key,
    required this.onChanged,
    this.onScan,
    this.phone = false,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onScan;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: phone ? colors.surfaceContainer : colors.surface,
        borderRadius: AppRadius.mdAll,
        border: phone ? null : Border.all(color: colors.outline),
      ),
      child: SizedBox(
        height: AppSize.field,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppIcon(AppIcons.search, color: colors.onSurfaceVariant),
            ),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: context.text.bodyLarge,
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: phone ? 'Cari produk' : 'Cari nama produk atau SKU',
                  hintStyle: context.text.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (phone && onScan != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxs),
                child: Semantics(
                  button: true,
                  label: 'Scan barcode',
                  child: Material(
                    color: colors.surface,
                    borderRadius: AppRadius.smAll,
                    child: InkWell(
                      borderRadius: AppRadius.smAll,
                      onTap: onScan,
                      child: const SizedBox.square(
                        dimension:
                            AppSize.touch - AppSpacing.xxs - AppSpacing.xxs,
                        child: Center(child: AppIcon(AppIcons.scan)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
