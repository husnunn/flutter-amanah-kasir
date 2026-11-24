# flutter-amanah-kasir

Aplikasi kasir (POS) multi-toko untuk Android, dibangun dengan Flutter. Tiga
peran dalam satu aplikasi: **kasir** (transaksi dan nota), **admin** (produk,
keuangan, laporan), dan **superadmin** (toko dan pengguna).

**Status: tahap UI.** Semua 11 layar dari spesifikasi sudah dibangun dengan
data contoh lokal. Belum ada Firebase, autentikasi, penyimpanan, cetak
Bluetooth, atau scan barcode.

## Dokumen referensi

- [`referensi/PRD & ERD Aplikasi amanah-kasir.md`](referensi/PRD%20%26%20ERD%20Aplikasi%20amanah-kasir.md): kebutuhan produk, peran, struktur Firestore.
- [`referensi/Spesifikasi UI Aplikasi Kasir Multi-Toko.md`](referensi/Spesifikasi%20UI%20Aplikasi%20Kasir%20Multi-Toko.md): token visual dan isi tiap layar.

## Menjalankan

Butuh Flutter 3.50.1 (Dart 3.14) dan Android 8+.

```bash
flutter pub get
flutter run
```

Halaman awal adalah **galeri layar** untuk membuka semua layar. Layout dipilih
dari lebar jendela: 900 dp ke atas memakai layout tablet, di bawahnya layout HP.

```bash
flutter analyze   # analisis statis
flutter test      # smoke test layar, logika, dan alur
```

## Struktur

```
lib/
  app/        MaterialApp, router alur antar layar
  dev/        galeri layar (halaman awal pratinjau)
  core/
    theme/    token (spasi, radius, ukuran), warna, tipografi, ThemeData
    icons/    ikon garis 24x24 (path SVG dari desain)
    utils/    format Rupiah/tanggal, helper kecil
    widgets/  komponen yang dipakai ulang (tombol, kartu, sidebar, dst.)
  features/
    auth/  kasir/  produk/  keuangan/  laporan/  superadmin/  admin/
assets/fonts/ Plus Jakarta Sans (SIL OFL 1.1)
```

Aturan kode: warna, ukuran font, dan spasi hanya berasal dari `core/theme`
(tidak ada nilai hardcode di widget), dan satu file tidak lebih dari 250 baris.

## Catatan

- Flutter 3.50 memindahkan Material ke paket `material_ui`; impor memakai
  `package:material_ui/material_ui.dart`, bukan `package:flutter/material.dart`.
- Hanya tema terang; dark mode belum ada di desain.
- Layar yang belum didesain (riwayat transaksi, void, laporan mingguan,
  pengaturan toko/printer, form tambah toko dan pengguna) menampilkan snackbar
  "segera hadir".
