import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/dashboard_data.dart';

/// Grafik batang pendapatan (fl_chart). Batang terakhir ("hari ini") berwarna
/// aksen, sisanya aksen muda. [compact] = varian HP: tanpa sumbu Y, nilai
/// (dalam ribu Rp) tampil di atas batang.
class RevenueBarChart extends StatelessWidget {
  const RevenueBarChart({super.key, required this.spec, this.compact = false});

  final ChartSpec spec;
  final bool compact;

  static final NumberFormat _axis = NumberFormat('0.#', 'id_ID');

  String _axisLabel(double v) {
    if (v == 0) return '0';
    return '${_axis.format(v / spec.axisDivisor)} ${spec.axisSuffix}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.app;
    final text = context.text;
    final muted = text.labelSmall?.copyWith(
      color: colors.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final last = spec.bars.length - 1;
    final gap = compact ? AppSpacing.xs : AppSpacing.xxs;

    final groups = [
      for (var i = 0; i < spec.bars.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: spec.bars[i].value,
              color: i == last ? colors.primary : app.accentMuted,
              width: AppSpacing.md,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.xxs),
              ),
              label: compact
                  ? BarChartRodLabel(
                      show: true,
                      text: formatNumber(spec.bars[i].value / 1000),
                      offset: const Offset(0, AppSpacing.xs),
                      style: text.labelSmall?.copyWith(
                        color: i == last
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    )
                  : const BarChartRodLabel(),
            ),
          ],
        ),
    ];

    return Semantics(
      label: 'Grafik pendapatan ${spec.bars.length} periode',
      child: ExcludeSemantics(
        child: BarChart(
          BarChartData(
            maxY: compact ? spec.maxY * 1.12 : spec.maxY,
            alignment: BarChartAlignment.spaceAround,
            groupsSpace: gap,
            barGroups: groups,
            borderData: FlBorderData(
              show: !compact,
              border: Border(bottom: BorderSide(color: app.borderInput)),
            ),
            gridData: FlGridData(
              show: !compact,
              drawVerticalLine: false,
              horizontalInterval: spec.interval,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: colors.outlineVariant, strokeWidth: 1),
            ),
            barTouchData: const BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: !compact,
                  reservedSize: AppSpacing.xxxl - AppSpacing.xxs,
                  interval: spec.interval,
                  getTitlesWidget: (v, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(_axisLabel(v), style: muted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: AppSpacing.xl,
                  getTitlesWidget: (v, meta) {
                    final label = spec.bars[v.toInt()].label;
                    final visible = spec.visibleLabels?.contains(label) ?? true;
                    return SideTitleWidget(
                      meta: meta,
                      child: visible
                          ? Text(
                              label,
                              style: muted?.copyWith(
                                color: compact && v.toInt() == last
                                    ? colors.onSurface
                                    : null,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
