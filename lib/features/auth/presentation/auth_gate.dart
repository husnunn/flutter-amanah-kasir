import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_router.dart';
import '../../kasir/state/cart_controller.dart';
import '../data/app_role.dart';
import '../data/app_session.dart';
import '../state/auth_providers.dart';
import 'forgot_password_sheet.dart';
import 'gate_views.dart';
import 'login_screen.dart';
import 'pilih_toko_screen.dart';

/// Pintu masuk aplikasi: memilih layar berdasarkan status login dan peran.
///
/// - belum masuk -> Login
/// - superadmin -> Toko & pengguna
/// - admin -> Pilih toko (bila lebih dari satu dan belum dipilih) -> Dashboard
/// - kasir -> Kasir
///
/// Layar-layar tujuan masih memakai data contoh; hanya identitas pengguna dan
/// nama toko yang berasal dari sesi.
class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  /// Keranjang kasir hidup selama sesi; dibuang saat keluar.
  CartController _cart = CartController();

  /// Rute yang ditumpuk Navigator (Pembayaran, Produk, dst.) tidak boleh
  /// menutupi layar baru setelah keluar atau ganti toko.
  void _popToRoot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthSignedOut) {
        _cart = CartController();
        _popToRoot();
      }
    });
    ref.listen<String?>(activeStoreIdProvider, (previous, next) {
      if (previous != next) _popToRoot();
    });

    return switch (ref.watch(authControllerProvider)) {
      AuthLoading() => const GateSplash(),
      AuthSignedOut(:final notice) => _LoginPage(notice: notice),
      AuthSignedIn(:final session) => _SignedInHome(
        session: session,
        cart: _cart,
      ),
    };
  }
}

class _LoginPage extends ConsumerWidget {
  const _LoginPage({required this.notice});

  final String? notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginControllerProvider);
    return LoginScreen(
      isLoading: login.isLoading,
      errorMessage: login.error,
      notice: notice,
      onSubmit: (email, password) =>
          ref.read(loginControllerProvider.notifier).signIn(email, password),
      onForgotPassword: () => showForgotPasswordSheet(context),
    );
  }
}

class _SignedInHome extends ConsumerWidget {
  const _SignedInHome({required this.session, required this.cart});

  final AppSession session;
  final CartController cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void signOut() => ref.read(authControllerProvider.notifier).signOut();

    if (session.role == AppRole.superadmin) {
      return AppRouter(
        onLogout: signOut,
        userId: session.uid,
        userName: session.name,
      ).tokoPenggunaPage(context);
    }

    return ref
        .watch(storesProvider)
        .when(
          loading: () => const GateSplash(),
          error: (_, _) => GateError(
            onRetry: () => ref.invalidate(storesProvider),
            onSignOut: signOut,
          ),
          data: (stores) {
            final activeId = ref.watch(activeStoreIdProvider);
            final active = stores.where((s) => s.id == activeId).firstOrNull;
            final multiStore = session.storeIds.length > 1;
            final router = AppRouter(
              onLogout: signOut,
              // Admin satu toko tidak punya toko lain untuk dipilih.
              onSwitchStore: multiStore
                  ? () => ref.read(activeStoreIdProvider.notifier).clear()
                  : () {},
              userName: session.name,
              storeName: active?.name ?? '',
              storeCount: session.storeIds.length,
            );

            if (session.role == AppRole.admin) {
              if (active == null) {
                return PilihTokoScreen(
                  userName: session.name,
                  stores: [
                    for (final (index, store) in stores.indexed)
                      store.toOption(index),
                  ],
                  onConfirm: (option) => ref
                      .read(activeStoreIdProvider.notifier)
                      .select(option.id),
                );
              }
              return router.dashboardPage(context);
            }
            return router.kasirPage(context, cart);
          },
        );
  }
}
