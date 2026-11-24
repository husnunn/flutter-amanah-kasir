import 'package:amanah_kasir/features/kasir/data/receipt_data.dart';
import 'package:amanah_kasir/features/kasir/state/cart_controller.dart';
import 'package:amanah_kasir/features/kasir/state/payment_controller.dart';
import 'package:amanah_kasir/features/produk/data/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(String id) => sampleProducts.firstWhere((p) => p.id == id);

void main() {
  group('CartController', () {
    test('contoh desain: 4 produk, 12 item, total Rp 58.500', () {
      final cart = CartController()..seedSample(sampleProducts);
      expect(cart.productCount, 4);
      expect(cart.itemCount, 12);
      expect(cart.subtotal, 59500);
      expect(cart.discount, 1000);
      expect(cart.total, 58500);
    });

    test('tambah dan kurangi; qty 0 menghapus baris', () {
      final cart = CartController();
      final kopi = _product('kopi-sachet');
      cart.increment(kopi);
      cart.increment(kopi);
      expect(cart.qtyOf(kopi), 2);
      cart.decrement(kopi);
      expect(cart.qtyOf(kopi), 1);
      cart.decrement(kopi);
      expect(cart.isEmpty, isTrue);
    });

    test('jumlah tidak melebihi stok', () {
      final cart = CartController();
      final telur = _product('telur'); // stok 3
      for (var i = 0; i < 10; i++) {
        cart.increment(telur);
      }
      expect(cart.qtyOf(telur), telur.stock);
    });

    test('diskon tidak bisa melebihi subtotal dan tidak negatif', () {
      final cart = CartController()..increment(_product('kopi-sachet'));
      cart.setDiscount(999999);
      expect(cart.total, 0);
      cart.setDiscount(-5);
      expect(cart.discount, 0);
      expect(cart.total, 1500);
    });

    test('clear mengosongkan item dan diskon', () {
      final cart = CartController()..seedSample(sampleProducts);
      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.discount, 0);
    });
  });

  group('PaymentController', () {
    test('kembalian dihitung dari uang diterima', () {
      final pay = PaymentController(total: 58500, initialReceived: 100000);
      expect(pay.change, 41500);
      expect(pay.canFinish, isTrue);
    });

    test('uang kurang: belum bisa selesai, tanpa kembalian', () {
      final pay = PaymentController(total: 58500, initialReceived: 50000);
      expect(pay.change, 0);
      expect(pay.canFinish, isFalse);
    });

    test('keypad: digit, 000, dan hapus', () {
      final pay = PaymentController(total: 58500)
        ..pressDigits('6')
        ..pressDigits('000')
        ..pressDigits('0');
      expect(pay.received, 60000);
      pay.backspace();
      expect(pay.received, 6000);
    });

    test('keypad dibatasi 9 digit', () {
      final pay = PaymentController(total: 1000, initialReceived: 123456789)
        ..pressDigits('5');
      expect(pay.received, 123456789);
    });

    test('nominal cepat selalu di atas total, unik, maksimal tiga', () {
      expect(PaymentController(total: 58500).quickAmounts, [
        60000,
        70000,
        100000,
      ]);
      expect(PaymentController(total: 100000).quickAmounts, [
        110000,
        120000,
        150000,
      ]);
      expect(PaymentController(total: 60000).quickAmounts, [
        70000,
        80000,
        100000,
      ]);
    });

    test('QRIS/transfer: langsung bisa selesai, dibayar = total', () {
      final pay = PaymentController(total: 58500)
        ..selectMethod(PaymentMethod.qris);
      expect(pay.canFinish, isTrue);
      expect(pay.paid, 58500);
      expect(pay.change, 0);
    });

    test('nota menyalin item, total, bayar, dan kembali', () {
      final cart = CartController()..seedSample(sampleProducts);
      final pay = PaymentController(total: cart.total, initialReceived: 100000);
      final receipt = ReceiptData.from(cart, pay);
      expect(receipt.lines.length, 4);
      expect(receipt.total, 58500);
      expect(receipt.paid, 100000);
      expect(receipt.change, 41500);
    });
  });

  group('Product', () {
    test('stok menipis dan margin', () {
      final telur = _product('telur');
      expect(telur.isLowStock, isTrue);
      expect(telur.margin, 3500);
      expect(_product('mi-instan').isLowStock, isFalse);
    });

    test('copyWith mengubah field tanpa mengubah id/sku', () {
      final updated = _product('telur')
          .copyWith(name: 'Telur Omega', price: 30000);
      expect(updated.name, 'Telur Omega');
      expect(updated.price, 30000);
      expect(updated.id, 'telur');
      expect(updated.sku, 'SKU-0108');
    });
  });
}
