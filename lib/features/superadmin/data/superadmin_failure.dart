/// Kegagalan kelola toko/pengguna dengan pesan siap tampil (Bahasa Indonesia).
class SuperadminFailure implements Exception {
  const SuperadminFailure(this.message, {this.code});

  final String message;

  /// Kode Firebase asal kegagalan (mis. `already-exists`); null bila tidak ada.
  final String? code;

  /// Kode dan email yang sudah dipakai ditampilkan di bawah field-nya.
  bool get isDuplicate => code == 'already-exists';

  /// Kode yang pesannya ditulis oleh Cloud Function kita sendiri (sudah
  /// Bahasa Indonesia dan spesifik, mis. "Kode toko TK01 sudah dipakai.").
  static const Set<String> _serverMessageCodes = {
    'already-exists',
    'invalid-argument',
    'not-found',
    'permission-denied',
    'failed-precondition',
  };

  /// Memetakan kode `FirebaseFunctionsException`/`FirebaseException` ke pesan.
  /// [serverMessage] dipakai hanya untuk kode di atas; kode lain (mis.
  /// `internal`) bisa membawa teks teknis berbahasa Inggris, jadi tidak ditampilkan.
  factory SuperadminFailure.fromCode(String code, [String? serverMessage]) {
    final detail = serverMessage?.trim() ?? '';
    if (_serverMessageCodes.contains(code) && detail.isNotEmpty) {
      return SuperadminFailure(detail, code: code);
    }
    return SuperadminFailure(code: code, switch (code) {
      'already-exists' => 'Data sudah ada.',
      'invalid-argument' => 'Data tidak valid. Periksa isian lalu coba lagi.',
      'not-found' => 'Data tidak ditemukan. Mungkin sudah dihapus.',
      'permission-denied' => 'Anda tidak berhak melakukan ini.',
      'unauthenticated' => 'Sesi berakhir. Masuk lagi untuk melanjutkan.',
      'unavailable' ||
      'deadline-exceeded' ||
      'network-request-failed' => 'Tidak ada koneksi internet. Coba lagi.',
      _ => 'Terjadi kendala. Coba lagi.',
    });
  }

  @override
  String toString() => message;
}
