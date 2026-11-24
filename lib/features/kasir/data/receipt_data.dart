import '../state/cart_controller.dart';
import '../state/payment_controller.dart';

class ReceiptLine {
  const ReceiptLine({
    required this.name,
    required this.qty,
    required this.subtotal,
  });

  final String name;
  final int qty;
  final int subtotal;
}

/// Salinan transaksi untuk pratinjau nota (nama dan harga saat transaksi).
class ReceiptData {
  const ReceiptData({
    required this.storeName,
    required this.receiptNo,
    required this.dateTime,
    required this.cashierName,
    required this.method,
    required this.lines,
    required this.discount,
    required this.total,
    required this.paid,
    required this.change,
  });

  final String storeName;
  final String receiptNo;
  final String dateTime;
  final String cashierName;
  final PaymentMethod method;
  final List<ReceiptLine> lines;
  final int discount;
  final int total;
  final int paid;
  final int change;

  /// Membentuk nota dari keranjang + pembayaran. Nomor nota dan waktu masih
  /// contoh tetap; pembuatan nomor nota sungguhan ada di tahap backend.
  factory ReceiptData.from(
    CartController cart,
    PaymentController payment, {
    String storeName = 'Toko Berkah Jaya',
    String cashierName = 'Rina',
  }) {
    return ReceiptData(
      storeName: storeName,
      receiptNo: 'TK01-20261124-121506-A3',
      dateTime: '24/11/2026 12:15',
      cashierName: cashierName,
      method: payment.method,
      lines: [
        for (final l in cart.lines)
          ReceiptLine(name: l.product.name, qty: l.qty, subtotal: l.subtotal),
      ],
      discount: cart.discount,
      total: cart.total,
      paid: payment.paid,
      change: payment.change,
    );
  }
}
