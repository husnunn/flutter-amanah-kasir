/// Kategori pengeluaran toko (PRD F-17).
const expenseCategories = <String>[
  'Belanja stok',
  'Listrik & air',
  'Gaji',
  'Sewa',
  'Transportasi',
  'Lainnya',
];

/// Isian formulir pengeluaran: tanggal, kategori, nominal, keterangan.
class ExpenseDraft {
  const ExpenseDraft({
    required this.date,
    required this.category,
    required this.amount,
    this.note = '',
  });

  final DateTime date;
  final String category;
  final int amount;
  final String note;
}
