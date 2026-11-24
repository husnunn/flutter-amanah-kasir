import 'package:material_ui/material_ui.dart';

/// Memberi [child] tinggi minimal. Bila ruang tersedia lebih pendek, konten
/// digulir vertikal alih-alih overflow (mis. tablet landscape yang rendah).
class MinHeightScroll extends StatelessWidget {
  const MinHeightScroll({
    super.key,
    required this.minHeight,
    required this.child,
  });

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight >= minHeight) return child;
        return SingleChildScrollView(
          child: SizedBox(height: minHeight, child: child),
        );
      },
    );
  }
}
