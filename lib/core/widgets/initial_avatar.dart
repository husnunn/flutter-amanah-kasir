import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

enum AvatarStyle { soft, outlined, dark }

/// Avatar lingkaran berisi inisial pengguna.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar(
    this.initials, {
    super.key,
    this.size = 40,
    this.avatarStyle = AvatarStyle.soft,
  });

  final String initials;
  final double size;
  final AvatarStyle avatarStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = context.app;
    final (background, foreground) = switch (avatarStyle) {
      AvatarStyle.soft => (colors.secondaryContainer, app.ink2),
      AvatarStyle.outlined => (colors.surface, app.ink2),
      AvatarStyle.dark => (app.ink2, colors.onSecondary),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: avatarStyle == AvatarStyle.outlined
            ? Border.all(color: colors.outline)
            : null,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Center(
          child: Text(
            initials,
            style: context.text.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
