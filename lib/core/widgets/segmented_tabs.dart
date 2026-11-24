import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Kontrol segmen (mis. Hari / Minggu / Bulan / Tahun). Segmen terpilih
/// berupa pil putih di atas trek abu-abu. [expand] membagi lebar sama rata (HP).
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.expand = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.app.track,
        borderRadius: AppRadius.mdAll,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              if (expand)
                Expanded(
                  child: _Segment(
                    label: labels[i],
                    selected: i == selectedIndex,
                    expand: true,
                    onTap: () => onChanged(i),
                  ),
                )
              else
                _Segment(
                  label: labels[i],
                  selected: i == selectedIndex,
                  expand: false,
                  onTap: () => onChanged(i),
                ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.expand,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? colors.surface : Colors.transparent,
        elevation: selected ? 1 : 0,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: onTap,
          child: SizedBox(
            height: AppSize.chip,
            child: Padding(
              padding: expand
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                widthFactor: expand ? null : 1,
                child: Text(
                  label,
                  style: context.text.bodySmall?.copyWith(
                    color: selected ? colors.onSurface : context.app.ink3,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
