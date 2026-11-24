import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../data/expense.dart';
import 'widgets/expense_form_parts.dart';

/// Catat pengeluaran (HP): nominal besar, kategori 3 kolom, tanggal,
/// keterangan, foto bukti (opsional), tombol simpan di bawah.
class PengeluaranScreen extends StatefulWidget {
  const PengeluaranScreen({
    super.key,
    this.storeName = 'Toko Berkah Jaya',
    this.initialAmount,
    this.initialNote,
    this.onBack,
    this.onSaved,
  });

  final String storeName;

  /// Isian awal (dipakai pratinjau desain); null = formulir kosong.
  final int? initialAmount;
  final String? initialNote;
  final VoidCallback? onBack;
  final ValueChanged<ExpenseDraft>? onSaved;

  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  late final _amount = TextEditingController(
    text: widget.initialAmount == null
        ? ''
        : formatRupiah(widget.initialAmount!),
  );
  late final _note = TextEditingController(text: widget.initialNote ?? '');
  int _category = 0;
  DateTime _date = DateTime(2026, 11, 24);
  late final _dateText = TextEditingController(text: formatDateLong(_date));

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    _dateText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    _dateText.text = formatDateLong(picked);
  }

  void _save() {
    final amount = parseDigits(_amount.text);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (amount == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Isi nominal pengeluaran')),
      );
      return;
    }
    widget.onSaved?.call(
      ExpenseDraft(
        date: _date,
        category: expenseCategories[_category],
        amount: amount,
        note: _note.text.trim(),
      ),
    );
    messenger.showSnackBar(
      const SnackBar(content: Text('Pengeluaran disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPhone),
                child: Row(
                  spacing: AppSpacing.sm,
                  children: [
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed:
                          widget.onBack ??
                          () => Navigator.of(context).maybePop(),
                      color: colors.onSurface,
                      style: IconButton.styleFrom(
                        minimumSize: const Size.square(AppSize.touch),
                        side: BorderSide(color: colors.outline),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      icon: const AppIcon(AppIcons.chevronLeft),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catat pengeluaran',
                          style: context.text.titleLarge,
                        ),
                        Text(
                          widget.storeName,
                          style: context.text.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPhone,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.lg,
                    children: [
                      AmountField.input(label: 'Nominal', controller: _amount),
                      ExpenseCategoryGrid(
                        selected: _category,
                        onSelect: (i) => setState(() => _category = i),
                      ),
                      AppTextField(
                        label: 'Tanggal',
                        leading: AppIcons.calendar,
                        readOnly: true,
                        controller: _dateText,
                        onTap: _pickDate,
                      ),
                      AppTextField(
                        label: 'Keterangan',
                        controller: _note,
                        hint: 'Contoh: beli telur di pasar',
                        maxLines: 3,
                      ),
                      const ExpenseProofUpload(),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPhone),
                child: AppButton(label: 'Simpan pengeluaran', onPressed: _save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
