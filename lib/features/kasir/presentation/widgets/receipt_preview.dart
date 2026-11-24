import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/dashed_divider.dart';
import '../../data/receipt_data.dart';
import '../../state/payment_controller.dart';

/// Pratinjau nota: header toko, nomor nota, daftar item, total, bayar/kembali.
/// Alamat dan telepon toko masih placeholder (diisi dari pengaturan toko).
class ReceiptPreview extends StatelessWidget {
  const ReceiptPreview({super.key, required this.data});

  final ReceiptData data;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final muted = text.bodySmall?.copyWith(color: context.app.ink3);
    final strong = text.bodySmall?.copyWith(fontWeight: FontWeight.w600);

    Widget row(
      String left,
      String right, {
      TextStyle? leftStyle,
      TextStyle? rightStyle,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: AppSpacing.sm,
        children: [
          Flexible(child: Text(left, style: leftStyle ?? text.bodySmall)),
          Text(right, style: rightStyle ?? text.bodySmall),
        ],
      );
    }

    return Semantics(
      label: 'Pratinjau nota',
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.sm,
          children: [
            Text(
              data.storeName,
              textAlign: TextAlign.center,
              style: text.titleSmall,
            ),
            Text(
              'Jl. [ALAMAT TOKO] · [NO. TELEPON]',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const DashedDivider(),
            row(
              data.receiptNo,
              data.dateTime,
              leftStyle: muted,
              rightStyle: muted,
            ),
            row(
              'Kasir: ${data.cashierName}',
              data.method.label,
              leftStyle: muted,
              rightStyle: muted,
            ),
            const DashedDivider(),
            for (final line in data.lines)
              row(
                '${line.qty} × ${line.name}',
                formatNumber(line.subtotal),
                rightStyle: strong,
              ),
            const DashedDivider(),
            if (data.discount > 0)
              row(
                'Diskon',
                formatRupiahNegative(data.discount).replaceFirst('Rp ', ''),
                leftStyle: muted,
                rightStyle: muted,
              ),
            row(
              'Total',
              formatRupiah(data.total),
              leftStyle: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              rightStyle: text.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (data.method == PaymentMethod.cash)
              row(
                'Bayar / Kembali',
                '${formatNumber(data.paid)} / ${formatNumber(data.change)}',
                leftStyle: muted,
                rightStyle: muted,
              )
            else
              row(
                'Dibayar via ${data.method.label}',
                formatNumber(data.paid),
                leftStyle: muted,
                rightStyle: muted,
              ),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                'Terima kasih atas kunjungan Anda',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
