import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/cart_controller.dart';

/// Bottom sheet untuk mengisi diskon per nota (PRD F-04).
Future<void> showDiscountSheet(BuildContext context, CartController cart) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DiscountSheet(cart: cart),
  );
}

class _DiscountSheet extends StatefulWidget {
  const _DiscountSheet({required this.cart});

  final CartController cart;

  @override
  State<_DiscountSheet> createState() => _DiscountSheetState();
}

class _DiscountSheetState extends State<_DiscountSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.cart.discount > 0 ? formatRupiah(widget.cart.discount) : '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(int value) {
    widget.cart.setDiscount(value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPhone,
        0,
        AppSpacing.screenPhone,
        AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Text('Diskon nota', style: context.text.titleMedium),
          AmountField.input(label: 'Nominal diskon', controller: _controller),
          Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: AppButton(
                  label: 'Hapus diskon',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _apply(0),
                ),
              ),
              Expanded(
                child: AppButton(
                  label: 'Terapkan',
                  onPressed: () => _apply(parseDigits(_controller.text)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
