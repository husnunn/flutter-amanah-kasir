import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

/// Garis putus-putus (pemisah bagian nota).
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  Widget build(BuildContext context) {
    final color = context.app.borderInput;
    return SizedBox(
      height: AppSize.borderThin,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / (_dash + _gap)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < count; i++)
                SizedBox(
                  width: _dash,
                  height: AppSize.borderThin,
                  child: ColoredBox(color: color),
                ),
            ],
          );
        },
      ),
    );
  }
}
