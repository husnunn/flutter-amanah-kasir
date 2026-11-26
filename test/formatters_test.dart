import 'package:amanah_kasir/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rupiah tanpa desimal dengan titik pemisah ribuan', () {
    expect(formatRupiah(0), 'Rp 0');
    expect(formatRupiah(58500), 'Rp 58.500');
    expect(formatRupiah(39230000), 'Rp 39.230.000');
  });

  test('diskon memakai tanda minus tipografis', () {
    expect(formatRupiahNegative(1000), '−Rp 1.000');
  });

  test('juta: koma desimal Indonesia', () {
    expect(formatJuta(2.5), '2,5 jt');
    expect(formatJuta(24.3), '24,3 jt');
  });

  test('parseDigits mengambil angka dari teks bebas', () {
    expect(parseDigits('Rp 150.000'), 150000);
    expect(parseDigits(''), 0);
    expect(parseDigits('abc'), 0);
  });

  test('inisial dari dua kata pertama', () {
    expect(initialsOf('Mi Instan Goreng'), 'MI');
    expect(initialsOf('Kopi Sachet'), 'KS');
    expect(initialsOf('Rina'), 'R');
    expect(initialsOf('  '), '');
  });

  test('tanggal panjang bahasa Indonesia', () {
    expect(formatDateLong(DateTime(2026, 11, 24)), 'Selasa, 24 November 2026');
    expect(formatDateLong(DateTime(2026, 1, 4)), 'Minggu, 4 Januari 2026');
  });

  test('tanggal pendek bahasa Indonesia', () {
    expect(formatDateShort(DateTime(2026, 11, 2)), '2 Nov 2026');
    expect(formatDateShort(DateTime(2026, 8, 17)), '17 Agu 2026');
  });

  test('RupiahInputFormatter memformat saat mengetik', () {
    const formatter = RupiahInputFormatter();
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '150000'),
    );
    expect(result.text, 'Rp 150.000');
    final cleared = formatter.formatEditUpdate(
      result,
      const TextEditingValue(text: 'Rp '),
    );
    expect(cleared.text, isEmpty);
  });
}
