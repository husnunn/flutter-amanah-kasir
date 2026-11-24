/// Kegagalan login/reset password dengan pesan siap tampil (Bahasa Indonesia).
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  /// Memetakan kode `FirebaseAuthException.code` ke pesan manusiawi.
  factory AuthFailure.fromCode(String code) {
    return AuthFailure(switch (code) {
      'invalid-email' => 'Format email tidak valid.',
      'user-disabled' => 'Akun ini dinonaktifkan. Hubungi pemilik toko.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-login-credentials' => 'Email atau password salah.',
      'too-many-requests' =>
        'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.',
      'network-request-failed' => 'Tidak ada koneksi internet.',
      _ => 'Terjadi kendala saat masuk. Coba lagi.',
    });
  }

  @override
  String toString() => message;
}

/// Alasan akun ditolak setelah berhasil login; sesi ditutup dan pesannya
/// ditampilkan di layar Login.
enum SessionRejection {
  noRole('Akun Anda belum diberi peran. Hubungi pemilik toko.'),
  inactiveUser('Akun Anda dinonaktifkan. Hubungi pemilik toko.'),
  noActiveStore('Toko Anda sedang nonaktif. Hubungi pemilik aplikasi.');

  const SessionRejection(this.message);

  final String message;
}
