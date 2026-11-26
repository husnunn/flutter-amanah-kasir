import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const String _locale = 'id_ID';

final NumberFormat _grouped = NumberFormat.decimalPattern(_locale);
final NumberFormat _oneDecimal = NumberFormat('0.#', _locale);

/// 58500 -> "58.500".
String formatNumber(num value) => _grouped.format(value);

/// 58500 -> "Rp 58.500" (Rupiah tanpa desimal, sesuai PRD).
String formatRupiah(num value) => 'Rp ${formatNumber(value)}';

/// 1000 -> "−Rp 1.000" (tanda minus tipografis, dipakai untuk diskon).
String formatRupiahNegative(num value) => '−${formatRupiah(value)}';

/// 2.5 -> "2,5 jt"; dipakai di sumbu grafik dan ringkasan.
String formatJuta(double value) => '${_oneDecimal.format(value)} jt';

/// Mengambil angka dari teks bebas: "Rp 150.000" -> 150000.
int parseDigits(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}

/// Memformat isian nominal menjadi "Rp 150.000" saat mengetik.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final amount = parseDigits(newValue.text);
    if (amount == 0) return const TextEditingValue();
    final text = formatRupiah(amount);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Inisial dari dua kata pertama: "Mi Instan Goreng" -> "MI".
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

const _dayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];
const _monthNames = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// DateTime(2026, 11, 2) -> "2 Nov 2026".
String formatDateShort(DateTime d) =>
    '${d.day} ${_monthShort[d.month - 1]} ${d.year}';

/// DateTime(2026, 11, 24) -> "Selasa, 24 November 2026".
String formatDateLong(DateTime d) =>
    '${_dayNames[d.weekday - 1]}, ${d.day} ${_monthNames[d.month - 1]} ${d.year}';
