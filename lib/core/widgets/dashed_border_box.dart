import 'dart:ui' show PathMetric;

import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Kotak dengan garis tepi putus-putus (area unggah, tombol "tambah").
/// Bisa ditekan bila [onTap] diisi.
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    this.onTap,
    this.radius = AppRadius.lgAll,
    this.color,
    this.background,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius radius;
  final Color? color;
  final Color? background;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final line = color ?? context.app.borderInput;
    return CustomPaint(
      foregroundPainter: _DashedPainter(color: line, radius: radius),
      child: Material(
        color: background ?? context.app.surfaceAlt,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color, required this.radius});

  final Color color;
  final BorderRadius radius;

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSize.borderMedium;
    final rect = (Offset.zero & size).deflate(AppSize.borderMedium / 2);
    final path = Path()..addRRect(radius.toRRect(rect));
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.radius != radius;
}
