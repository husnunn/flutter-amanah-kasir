import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/cart_controller.dart';

/// Ringkasan pesanan di halaman pembayaran: item, subtotal, diskon, total.
class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.cart,
    this.expand = false,
  });

  final CartController cart;

  /// Tablet: kartu memenuhi tinggi dan total menempel di bawah.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final muted = text.bodyMedium?.copyWith(color: context.app.ink3);
    final strong = text.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    final rows = <Widget>[
      for (final line in cart.lines) _LineRow(line: line, strong: strong),
    ];

    return AppCard(
      radius: AppRadius.xxlAll,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ringkasan pesanan', style: text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          if (expand) Expanded(child: ListView(children: rows)) else ...rows,
          const SizedBox(height: AppSpacing.md),
          _Row(
            label: 'Subtotal',
            value: formatRupiah(cart.subtotal),
            style: muted,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Diskon',
            value: formatRupiahNegative(cart.discount),
            style: muted,
            valueStyle: strong?.copyWith(color: context.colors.error),
          ),
          const Divider(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: AppSpacing.sm,
            children: [
              Text(
                'Total tagihan',
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatRupiah(cart.total),
                    style: text.displayLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.style,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? style;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style:
              valueStyle ??
              context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.strong});

  final CartLine line;
  final TextStyle? strong;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: AppSpacing.sm,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '${line.qty}× ',
                  style: text.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: line.product.name,
                      style: text.bodyMedium?.copyWith(
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(formatRupiah(line.subtotal), style: strong),
          ],
        ),
      ),
    );
  }
}
