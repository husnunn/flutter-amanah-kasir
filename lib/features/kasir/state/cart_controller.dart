import 'package:material_ui/material_ui.dart';

import '../../produk/data/product.dart';

class CartLine {
  const CartLine(this.product, this.qty);

  final Product product;
  final int qty;

  int get subtotal => product.price * qty;
}

/// Keranjang kasir: item, jumlah, dan diskon per nota. Hanya state lokal;
/// belum terhubung ke penyimpanan.
class CartController extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};
  int _discount = 0;

  List<CartLine> get lines => _lines.values.toList(growable: false);
  bool get isEmpty => _lines.isEmpty;
  int get productCount => _lines.length;
  int get itemCount => _lines.values.fold(0, (sum, l) => sum + l.qty);
  int get subtotal => _lines.values.fold(0, (sum, l) => sum + l.subtotal);
  int get discount => _discount > subtotal ? subtotal : _discount;
  int get total => subtotal - discount;

  int qtyOf(Product product) => _lines[product.id]?.qty ?? 0;

  /// Menambah satu; tidak melebihi stok.
  void increment(Product product) {
    final qty = qtyOf(product);
    if (qty >= product.stock) return;
    _lines[product.id] = CartLine(product, qty + 1);
    notifyListeners();
  }

  void decrement(Product product) {
    final qty = qtyOf(product);
    if (qty <= 1) {
      _lines.remove(product.id);
    } else {
      _lines[product.id] = CartLine(product, qty - 1);
    }
    notifyListeners();
  }

  void setDiscount(int value) {
    _discount = value < 0 ? 0 : value;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _discount = 0;
    notifyListeners();
  }

  /// Mengisi keranjang dengan data contoh yang sama seperti di desain.
  void seedSample(List<Product> products) {
    const sample = {
      'mi-instan': 5,
      'telur': 1,
      'air-mineral': 2,
      'kopi-sachet': 4,
    };
    _lines.clear();
    for (final entry in sample.entries) {
      final product = products.firstWhere((p) => p.id == entry.key);
      _lines[product.id] = CartLine(product, entry.value);
    }
    _discount = 1000;
    notifyListeners();
  }
}
