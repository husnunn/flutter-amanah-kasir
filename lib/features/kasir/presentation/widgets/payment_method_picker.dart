import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/payment_controller.dart';

/// Tiga pilihan metode bayar (Tunai, QRIS, Transfer) sebagai kartu radio.
/// [compact] = ikon di atas label, untuk lebar HP.
class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.payment,
    this.compact = false,
  });

  final PaymentController payment;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.sm,
      children: [
        Text('Metode pembayaran', style: context.text.titleMedium),
        Row(
          spacing: AppSpacing.sm,
          children: [
            for (final method in PaymentMethod.values)
              Expanded(
                child: SelectableOptionCard(
                  label: method.label,
                  icon: method.icon,
                  selected: payment.method == method,
                  vertical: compact,
                  height: compact
                      ? AppSize.fieldTall + AppSpacing.md
                      : AppSize.optionTall,
                  onTap: () => payment.selectMethod(method),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
