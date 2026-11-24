import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/coming_soon.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/expense.dart';

/// Pilihan kategori pengeluaran: grid 3 kolom berisi kartu pilihan.
class ExpenseCategoryGrid extends StatelessWidget {
  const ExpenseCategoryGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.xs,
      children: [
        const FieldLabel('Kategori'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          mainAxisExtent: AppSize.fieldDense,
          children: [
            for (var i = 0; i < expenseCategories.length; i++)
              SelectableOptionCard(
                label: expenseCategories[i],
                selected: i == selected,
                height: AppSize.fieldDense,
                radius: AppRadius.mdAll,
                onTap: () => onSelect(i),
              ),
          ],
        ),
      ],
    );
  }
}

/// Area unggah foto bukti/nota (opsional), berbingkai garis putus-putus.
class ExpenseProofUpload extends StatelessWidget {
  const ExpenseProofUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashedBorderBox(
      onTap: () => showComingSoon(context, 'Unggah foto bukti'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.outline),
            ),
            child: SizedBox.square(
              dimension: AppSize.touch,
              child: Center(
                child: AppIcon(
                  AppIcons.camera,
                  size: AppSize.iconLg,
                  color: colors.primary,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Foto bukti / nota',
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Opsional · kamera atau galeri',
                style: context.text.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
