import 'package:material_ui/material_ui.dart';

import '../../../core/icons/app_icons.dart';

enum PaymentMethod {
  cash('Tunai', AppIcons.cash),
  qris('QRIS', AppIcons.qr),
  transfer('Transfer', AppIcons.bank);

  const PaymentMethod(this.label, this.icon);

  final String label;
  final AppIconData icon;
}

/// State pembayaran: metode, uang diterima (dari keypad), kembalian.
/// QRIS dan transfer hanya dicatat sebagai metode bayar (PRD F-05).
class PaymentController extends ChangeNotifier {
  PaymentController({
    required this.total,
    this.method = PaymentMethod.cash,
    int initialReceived = 0,
  }) : _received = initialReceived;

  static const int _maxDigits = 9;

  final int total;
  PaymentMethod method;
  int _received;

  bool get isCash => method == PaymentMethod.cash;
  int get received => _received;
  int get paid => isCash ? _received : total;
  int get change => isCash && _received > total ? _received - total : 0;
  bool get canFinish => !isCash || _received >= total;

  /// Nominal cepat: kelipatan 10 rb, 50 rb, dan 100 rb tepat di atas total
  /// ("Uang pas" disediakan terpisah di UI). Paling banyak tiga opsi.
  List<int> get quickAmounts {
    int above(int step) => (total ~/ step + 1) * step;
    final base = above(10000);
    final options = <int>{base, base + 10000, above(50000), above(100000)};
    return (options.toList()..sort()).take(3).toList();
  }

  void selectMethod(PaymentMethod value) {
    method = value;
    notifyListeners();
  }

  void pressDigits(String digits) {
    final next = '$_received$digits';
    if (next.length > _maxDigits) return;
    _received = int.parse(next);
    notifyListeners();
  }

  void backspace() {
    _received ~/= 10;
    notifyListeners();
  }

  void setReceived(int value) {
    _received = value;
    notifyListeners();
  }

  void setExact() => setReceived(total);
}
