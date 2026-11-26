import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Kolom tabel daftar: judul, lebar relatif ([flex]), dan rata kanan untuk angka.
class DirectoryColumn {
  const DirectoryColumn(this.label, this.flex, {this.alignEnd = false});

  final String label;
  final int flex;
  final bool alignEnd;
}

/// Kerangka tabel daftar toko/pengguna: kartu dengan judul kolom di atas dan
/// isi yang bisa digulir di bawahnya.
class DirectoryTable extends StatelessWidget {
  const DirectoryTable({super.key, required this.columns, required this.child});

  final List<DirectoryColumn> columns;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final head = context.text.labelMedium?.copyWith(color: context.app.ink3);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ColoredBox(
            color: context.app.surfaceAlt,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  for (final column in columns)
                    Expanded(
                      flex: column.flex,
                      child: Text(
                        column.label,
                        textAlign: column.alignEnd
                            ? TextAlign.end
                            : TextAlign.start,
                        style: head,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Satu baris tabel. [cells] mengikuti urutan dan lebar [columns]. Baris
/// terpilih berlatar hijau sangat muda.
class DirectoryRow extends StatelessWidget {
  const DirectoryRow({
    super.key,
    required this.columns,
    required this.cells,
    required this.selected,
    required this.onTap,
  }) : assert(columns.length == cells.length);

  final List<DirectoryColumn> columns;
  final List<Widget> cells;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? context.app.selectedRow : colors.surface,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.outlineVariant)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  for (var i = 0; i < cells.length; i++)
                    Expanded(flex: columns[i].flex, child: cells[i]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sel berisi lencana: mengecil bila kolom sempit (tablet kecil, font besar)
/// alih-alih terpotong.
class FitCell extends StatelessWidget {
  const FitCell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: child,
  );
}
