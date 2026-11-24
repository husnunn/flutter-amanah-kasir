import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../state/cart_controller.dart';
import '../../state/payment_controller.dart';
import 'cash_panel.dart';
import 'numeric_keypad.dart';
import 'payment_method_picker.dart';
import 'payment_summary_card.dart';

class PaymentTabletBody extends StatelessWidget {
  const PaymentTabletBody({
    super.key,
    required this.cart,
    required this.payment,
    required this.onCancel,
    required this.onFinish,
  });

  final CartController cart;
  final PaymentController payment;
  final VoidCallback onCancel;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final summaryWidth = (constraints.maxWidth * 0.34).clamp(
          AppLayout.paymentSummaryMin,
          AppLayout.paymentSummary,
        );
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenTablet),
          child: Row(
            spacing: AppSpacing.xl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: summaryWidth,
                child: PaymentSummaryCard(cart: cart, expand: true),
              ),
              Expanded(
                child: AppCard(
                  radius: AppRadius.xxlAll,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.xl,
                    children: [
                      PaymentMethodPicker(payment: payment),
                      Expanded(
                        child: SingleChildScrollView(
                          child: payment.isCash
                              ? Row(
                                  spacing: AppSpacing.xl,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: CashPanel(payment: payment),
                                    ),
                                    SizedBox(
                                      width: AppLayout.keypad,
                                      child: NumericKeypad(
                                        onDigits: payment.pressDigits,
                                        onBackspace: payment.backspace,
                                      ),
                                    ),
                                  ],
                                )
                              : NonCashNotice(payment: payment),
                        ),
                      ),
                      Row(
                        spacing: AppSpacing.sm,
                        children: [
                          AppButton(
                            label: 'Batal',
                            variant: AppButtonVariant.secondary,
                            expand: false,
                            onPressed: onCancel,
                          ),
                          Expanded(
                            child: AppButton(
                              label: 'Selesaikan & cetak nota',
                              icon: AppIcons.printer,
                              onPressed: onFinish,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PaymentPhoneBody extends StatelessWidget {
  const PaymentPhoneBody({
    super.key,
    required this.cart,
    required this.payment,
    required this.onFinish,
  });

  final CartController cart;
  final PaymentController payment;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPhone),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.lg,
              children: [
                PaymentSummaryCard(cart: cart),
                PaymentMethodPicker(payment: payment, compact: true),
                if (payment.isCash) ...[
                  CashPanel(payment: payment),
                  NumericKeypad(
                    onDigits: payment.pressDigits,
                    onBackspace: payment.backspace,
                  ),
                ] else
                  NonCashNotice(payment: payment),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(top: BorderSide(color: context.colors.outline)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: 'Selesaikan & cetak nota',
                icon: AppIcons.printer,
                onPressed: onFinish,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
