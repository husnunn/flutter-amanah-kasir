import 'store_record.dart';

/// Membuat pengguna baru. Melempar `SuperadminFailure` bila gagal.
typedef CreateUser = Future<void> Function(NewUserInput input);

/// Isian formulir "Tambah pengguna".
class NewUserInput {
  const NewUserInput({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.storeIds,
  });

  final String name;
  final String email;
  final String password;
  final UserRole role;
  final List<String> storeIds;

  static const int minPasswordLength = 8;
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  String get cleanName => name.trim();
  String get cleanEmail => email.trim().toLowerCase();

  /// Pesan kesalahan pertama, atau null bila isian sah. Aturannya selaras
  /// dengan `validUser` di firestore.rules.
  String? validate() {
    if (cleanName.isEmpty) return 'Nama wajib diisi.';
    if (!_emailPattern.hasMatch(cleanEmail)) return 'Email tidak valid.';
    if (password.length < minPasswordLength) {
      return 'Password minimal $minPasswordLength karakter.';
    }
    return switch (role) {
      UserRole.kasir when storeIds.length != 1 =>
        'Kasir harus terikat ke tepat satu toko.',
      UserRole.admin when storeIds.isEmpty =>
        'Admin harus mengelola minimal satu toko.',
      _ => null,
    };
  }
}
