/// Peran pengguna; nilainya sama dengan claim `role` di ID token.
enum AppRole {
  superadmin('Superadmin'),
  admin('Admin'),
  kasir('Kasir');

  const AppRole(this.label);

  final String label;

  /// Mengurai nilai claim; null bila kosong atau tidak dikenal.
  static AppRole? tryParse(Object? value) {
    for (final role in values) {
      if (role.name == value) return role;
    }
    return null;
  }
}
