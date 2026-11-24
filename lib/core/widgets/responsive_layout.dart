import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/theme.dart';
import 'state_view.dart';

/// Memilih layout tablet atau HP berdasarkan lebar induk (batas 900 dp).
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.tablet,
    required this.phone,
  });

  final WidgetBuilder tablet;
  final WidgetBuilder phone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= AppLayout.tabletBreakpoint
          ? tablet(context)
          : phone(context),
    );
  }
}

/// Membatasi lebar konten (mis. layar HP yang dibuka di tablet) dan
/// menaruhnya di tengah atas.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.phoneMaxContent,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Layar yang hanya didesain untuk tablet; di HP tampil keterangan sopan
/// alih-alih layout yang patah.
class TabletOnly extends StatelessWidget {
  const TabletOnly({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tablet: (_) => child,
      phone: (_) => const Scaffold(
        body: SafeArea(
          child: StateView(
            icon: AppIcons.dashboard,
            title: 'Dirancang untuk tablet',
            message:
                'Putar perangkat ke landscape atau buka di tablet '
                'untuk melihat layar ini.',
          ),
        ),
      ),
    );
  }
}
