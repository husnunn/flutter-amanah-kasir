# flutter-amanah-kasir

Aplikasi kasir (POS) multi-toko untuk Android, dibangun dengan Flutter. Tiga
peran dalam satu aplikasi: **kasir** (transaksi dan nota), **admin** (produk,
keuangan, laporan), dan **superadmin** (toko dan pengguna).

**Status:** UI 11 layar selesai, dan **login sungguhan** sudah terhubung ke
Firebase (Auth, peran dari custom claims, pilih toko, Security Rules, Cloud
Functions). Layar setelah login (Kasir, Dashboard, Produk, dst.) **masih memakai
data contoh**; penyimpanan transaksi/produk ke Firestore, cetak Bluetooth, dan
scan barcode belum dibuat.

**Mulai di sini:** [`docs/firebase-setup.md`](docs/firebase-setup.md) memandu
langkah demi langkah, dari mencoba dengan emulator sampai project Firebase asli.

## Dokumen referensi

- [`referensi/PRD & ERD Aplikasi amanah-kasir.md`](referensi/PRD%20%26%20ERD%20Aplikasi%20amanah-kasir.md): kebutuhan produk, peran, struktur Firestore.
- [`referensi/Spesifikasi UI Aplikasi Kasir Multi-Toko.md`](referensi/Spesifikasi%20UI%20Aplikasi%20Kasir%20Multi-Toko.md): token visual dan isi tiap layar.

## Menjalankan

Butuh Flutter 3.50.1 (Dart 3.14) dan Android 8+.

```bash
flutter pub get
```

Tiga mode (detail di [`docs/firebase-setup.md`](docs/firebase-setup.md)):

```bash
flutter run                                  # project Firebase asli (setelah flutterfire configure)
flutter run --dart-define=USE_EMULATOR=true  # Firebase Emulator di komputer
flutter run --dart-define=GALLERY=true       # galeri layar dengan data contoh, tanpa Firebase
```

Tanpa konfigurasi apa pun, aplikasi menampilkan layar panduan "Firebase belum
disiapkan". Layout dipilih dari lebar jendela: 900 dp ke atas memakai layout
tablet, di bawahnya layout HP.

```bash
flutter analyze   # analisis statis
flutter test      # layar, logika, alur, dan login (repositori palsu)
```

Tes backend (butuh Node 22+ dan Java 21+; emulator diunduh otomatis):

```bash
cd firebase-tests && npm install && npm test        # Security Rules Firestore + Storage
cd firebase-tests && npm run smoke                  # Auth + Firestore + Functions end-to-end
cd functions && npm install && npm test             # logika claims
```

## Struktur

```
lib/
  app/        MaterialApp, router alur antar layar
  dev/        galeri layar (data contoh)
  core/
    firebase/ konfigurasi lingkungan (--dart-define) dan inisialisasi Firebase
    theme/    token (spasi, radius, ukuran), warna, tipografi, ThemeData
    icons/    ikon garis 24x24 (path SVG dari desain)
    utils/    format Rupiah/tanggal, helper kecil
    widgets/  komponen yang dipakai ulang (tombol, kartu, sidebar, dst.)
  features/
    auth/     repositori Firebase, state Riverpod, Login, AuthGate per peran
    kasir/  produk/  keuangan/  laporan/  superadmin/  admin/
firestore.rules  storage.rules  firebase.json   aturan keamanan dan konfigurasi emulator
functions/       Cloud Functions (upsertUser, setUserActive, setStoreActive) + skrip
firebase-tests/  tes Security Rules dan smoke test di emulator
docs/            panduan setup Firebase
assets/fonts/    Plus Jakarta Sans (SIL OFL 1.1)
```

Aturan kode: warna, ukuran font, dan spasi hanya berasal dari `core/theme`
(tidak ada nilai hardcode di widget), dan satu file tidak lebih dari 250 baris.

## Catatan

- Flutter 3.50 memindahkan Material ke paket `material_ui`; impor memakai
  `package:material_ui/material_ui.dart`, bukan `package:flutter/material.dart`.
- Hanya tema terang; dark mode belum ada di desain.
- Kunci service account Firebase **tidak boleh** di-commit (sudah masuk `.gitignore`).
- Layar yang belum didesain (riwayat transaksi, void, laporan mingguan,
  pengaturan toko/printer, form tambah toko dan pengguna) menampilkan snackbar
  "segera hadir".
