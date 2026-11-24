import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/widgets.dart';
import '../data/receipt_data.dart';
import '../state/cart_controller.dart';
import '../state/payment_controller.dart';
import 'widgets/payment_header.dart';
import 'widgets/payment_layouts.dart';

/// Pembayaran: ringkasan pesanan, metode bayar, uang diterima + keypad,
/// kembalian. Tablet = dua kolom; HP = satu kolom dengan tombol selesai di bawah.
class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({
    super.key,
    required this.cart,
    this.initialReceived = 0,
    this.storeName = 'Toko Berkah Jaya',
    this.cashierName = 'Rina',
    this.receiptNo = 'TK01-20261124-121506-A3',
    this.onBack,
    this.onFinish,
  });

  final CartController cart;

  /// Uang diterima awal; 0 untuk alur nyata, diisi untuk pratinjau desain.
  final int initialReceived;
  final String storeName;
  final String cashierName;
  final String receiptNo;
  final VoidCallback? onBack;
  final ValueChanged<ReceiptData>? onFinish;

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  late final PaymentController _payment = PaymentController(
    total: widget.cart.total,
    initialReceived: widget.initialReceived,
  );

  @override
  void dispose() {
    _payment.dispose();
    super.dispose();
  }

  void _back() => (widget.onBack ?? () => Navigator.of(context).maybePop())();

  void _finish() {
    widget.onFinish?.call(
      ReceiptData.from(
        widget.cart,
        _payment,
        storeName: widget.storeName,
        cashierName: widget.cashierName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PaymentHeader(
            storeName: widget.storeName,
            cashierName: widget.cashierName,
            receiptNo: widget.receiptNo,
            onBack: _back,
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _payment,
              builder: (context, _) => ResponsiveLayout(
                tablet: (_) => PaymentTabletBody(
                  cart: widget.cart,
                  payment: _payment,
                  onCancel: _back,
                  onFinish: _payment.canFinish ? _finish : null,
                ),
                phone: (_) => PaymentPhoneBody(
                  cart: widget.cart,
                  payment: _payment,
                  onFinish: _payment.canFinish ? _finish : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
