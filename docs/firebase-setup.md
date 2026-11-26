# Panduan setup Firebase

Panduan ini membawa Anda dari nol sampai bisa **login ke aplikasi dengan akun
sungguhan**. Ada dua jalur; Anda boleh mulai dari Bagian 1 (tanpa akun Google
dan tanpa biaya) lalu lanjut ke Bagian 2.

| | Bagian 1: Emulator | Bagian 2: Project asli |
| --- | --- | --- |
| Butuh akun Google | Tidak | Ya |
| Biaya | Gratis | Gratis (paket Spark); Cloud Functions tidak dipakai |
| Waktu | ± 10 menit | ± 30-45 menit |
| Cocok untuk | Mencoba semua skenario login, mengembangkan | Dipakai di toko sungguhan |

## Prasyarat

- **Flutter 3.50.1** atau lebih baru (`flutter --version`; `flutter upgrade` bila lebih lama).
- **Node.js 22+** (untuk Cloud Functions dan skrip) dan **Java 21+** (untuk emulator Firestore).
- **Android Studio** dengan satu emulator, atau HP Android dengan USB debugging.
- Pasang Firebase CLI sekali saja:

```bash
npm install -g firebase-tools
```

Ambil dependensi proyek (sekali):

```bash
cd functions && npm install && cd ..
```

```bash
cd firebase-tests && npm install && cd ..
```

---

## Bagian 1: Coba dengan Firebase Emulator

Emulator menjalankan Auth, Firestore, dan Cloud Functions di komputer Anda. Tidak
ada data atau akun sungguhan yang tersentuh.

**1. Jalankan emulator** (biarkan terminal ini terbuka):

```bash
firebase emulators:start --project demo-amanah-kasir
```

Panel emulator ada di http://localhost:4000 (lihat user, dokumen, dan log).

**2. Isi data demo** di terminal kedua:

```bash
FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node functions/scripts/seed-emulator.mjs
```

Skrip ini menolak berjalan tanpa dua variabel tersebut, jadi tidak mungkin
menulis data demo ke project asli.

**3. Jalankan aplikasi** di terminal ketiga:

Emulator Android:

```bash
flutter run --dart-define=USE_EMULATOR=true
```

HP fisik (satu jaringan Wi-Fi dengan komputer; ganti IP dengan IP LAN komputer Anda):

```bash
flutter run --dart-define=USE_EMULATOR=true --dart-define=EMULATOR_HOST=192.168.1.10
```

Emulator Android melihat komputer Anda sebagai `10.0.2.2` (itulah default-nya).
Pada HP fisik, pastikan firewall komputer tidak memblokir port 9099, 8080, dan 5001.

**4. Coba semua skenario login.** Semua akun memakai password `Password123!`.

| Email | Peran | Yang seharusnya terjadi |
| --- | --- | --- |
| `superadmin@amanah.test` | Superadmin | Masuk ke layar Toko & pengguna |
| `admin@amanah.test` | Admin 3 toko | Layar **Pilih toko** (hanya 2 toko aktif; TK03 nonaktif), lalu Dashboard |
| `admin1@amanah.test` | Admin 1 toko | Langsung Dashboard |
| `kasir@amanah.test` | Kasir | Langsung layar Kasir |
| `kasir.nonaktif@amanah.test` | Kasir dinonaktifkan | Ditolak: "Akun ini dinonaktifkan" |
| `kasir.tokonon@amanah.test` | Kasir di toko nonaktif | Kembali ke Login: "Toko Anda sedang nonaktif" |
| `tanpaperan@amanah.test` | Akun tanpa peran | Kembali ke Login: "Akun Anda belum diberi peran" |

Coba juga password salah dan **Lupa password?** (di emulator, tautan reset tidak
dikirim lewat email; lihat tautannya di panel emulator, tab Authentication).

> Layar setelah login (Kasir, Dashboard, Produk, dst.) **masih memakai data contoh**.
> Yang sudah sungguhan: login, peran, nama pengguna, dan nama toko.

Hentikan emulator dengan `Ctrl+C`. Data emulator hilang saat berhenti, jalankan
skrip seed lagi bila perlu.

---

## Bagian 2: Project Firebase asli

### Langkah 1. Buat project

1. Buka https://console.firebase.google.com dan login dengan akun Google Anda.
2. **Create a project** (atau **Add project**). Beri nama, misalnya `amanah-kasir`.
3. Google Analytics boleh dinonaktifkan; aplikasi ini tidak memakainya.
4. Catat **Project ID** (tampil di *Project settings*, mis. `amanah-kasir-ab12c`). Anda akan memakainya di langkah-langkah berikut sebagai `ID-PROJECT`.

### Langkah 2. Aktifkan login email + password

1. Menu **Build > Authentication > Get started**.
2. Tab **Sign-in method**, pilih **Email/Password**, aktifkan, **Save**. Jangan aktifkan "Email link".
3. Tab **Settings > User actions**: nonaktifkan **Enable create (sign-up)** bila opsinya tersedia. Aplikasi tidak punya pendaftaran publik; akun hanya dibuat oleh pengelola lewat Admin SDK.

### Langkah 3. Buat database Firestore

1. Menu **Build > Firestore Database > Create database**.
2. **Location: `asia-southeast2` (Jakarta)**. Lokasi tidak bisa diubah setelah dibuat, jadi pilih sekarang.
3. Pilih **Production mode** (aturan keamanan kita deploy sendiri di Langkah 7).

### Langkah 4. Paket Spark (gratis) sudah cukup

Aplikasi berjalan sepenuhnya di paket **Spark**: login, peran, Security Rules,
tambah pengguna, dan aktif/nonaktif toko dilakukan langsung dari aplikasi ke
Firestore, tanpa Cloud Functions. **Anda tidak perlu upgrade ke Blaze.**

Folder `functions/` masih ada sebagai jalur opsional bila suatu saat memakai
Blaze (lihat Langkah 8); aplikasi tidak bergantung padanya.

### Langkah 5. Pasang dan login CLI

```bash
firebase login
```

```bash
dart pub global activate flutterfire_cli
```

Pastikan `~/.pub-cache/bin` ada di `PATH` agar perintah `flutterfire` dikenali.

### Langkah 6. Hubungkan aplikasi ke project

Dari folder utama repo. Perintah ini mengisi `lib/firebase_options.dart`,
membuat `android/app/google-services.json`, dan menambahkan plugin Gradle yang diperlukan:

```bash
flutterfire configure --project=ID-PROJECT --platforms=android --android-package-name=id.amanah.kasir
```

Arahkan juga Firebase CLI ke project yang sama (mengganti `demo-amanah-kasir` di `.firebaserc`):

```bash
firebase use ID-PROJECT
```

> **Soal keamanan:** konfigurasi klien Firebase (`firebase_options.dart`,
> `google-services.json`) bukan rahasia dan aman di-commit. Perlindungan datanya
> ada di Security Rules. Tetap disarankan membatasi API key di Google Cloud
> Console > **APIs & Services > Credentials** ke aplikasi Android
> `id.amanah.kasir`.

### Langkah 7. Deploy Security Rules

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Selalu pakai `--only`: `firebase deploy` tanpa itu ikut mencoba mendeploy Cloud
Functions dan gagal di paket Spark. **Deploy ulang aturan setiap kali
`firestore.rules` berubah**; aplikasi yang lebih baru bisa menampilkan "Ditolak
Security Rules" bila aturan di server masih versi lama.

Aturan lengkap ada di `firestore.rules`. Storage aktif belakangan, saat fitur
foto produk dibangun.

### Langkah 8. (Opsional, butuh Blaze) Deploy Cloud Functions

Tidak diperlukan di paket Spark; lewati langkah ini.

```bash
firebase deploy --only functions
```

Pada deploy pertama Firebase akan meminta mengaktifkan beberapa API (Cloud Build,
Artifact Registry, dst.); jawab **Y**. Fungsi berada di region `asia-southeast2`.

### Langkah 9. Buat superadmin pertama

Skrip memakai Admin SDK sehingga butuh kunci service account:

1. Console: **Project settings (ikon roda gigi) > Service accounts > Generate new private key**.
2. Simpan berkas JSON **di luar repo**, mis. `~/rahasia/amanah-kasir-admin.json`. Berkas ini setara kunci master project: jangan di-commit, jangan dibagikan, hapus bila sudah tidak dipakai. (`.gitignore` sudah menolak pola `*-firebase-adminsdk-*.json` dan `serviceAccount*.json`.)
3. Jalankan (ganti nilainya):

```bash
GOOGLE_APPLICATION_CREDENTIALS=~/rahasia/amanah-kasir-admin.json node functions/scripts/create-superadmin.mjs --project ID-PROJECT --email pemilik@contoh.com --name "Nama Pemilik"
```

Skrip menampilkan target ("PROJECT ASLI"), meminta konfirmasi, lalu menanyakan
password (minimal 8 karakter).

### Langkah 10. Buat toko dan pengguna pertama

Sampai layar kelola pengguna di aplikasi selesai, buat lewat skrip (kunci
service account yang sama, tambahkan `GOOGLE_APPLICATION_CREDENTIALS=...` di depan
tiap perintah). Toko dulu:

```bash
node functions/scripts/provision.mjs store --project ID-PROJECT --id tk01 --code TK01 --name "Toko Berkah Jaya" --address "Jl. Contoh No. 1, Surabaya"
```

Lalu admin (boleh beberapa toko, pisahkan dengan koma) dan kasir (tepat satu toko):

```bash
node functions/scripts/provision.mjs user --project ID-PROJECT --email admin@contoh.com --name "Sari Ayu" --role admin --stores tk01
```

```bash
node functions/scripts/provision.mjs user --project ID-PROJECT --email kasir@contoh.com --name "Rina Wati" --role kasir --stores tk01
```

### Langkah 11. Jalankan aplikasi

```bash
flutter run
```

Login dengan salah satu akun tadi. Selesai.

---

## Cara kerja peran dan akses

- Peran dan toko dibaca dari dokumen **`users/{uid}`** (`role`:
  `superadmin`/`admin`/`kasir`, `storeIds`, `isActive`). Dokumen yang sama dipakai
  aplikasi dan Security Rules, jadi tidak ada custom claims dan tidak perlu
  Cloud Functions.
- Hanya superadmin yang boleh menulis `users` (membuat admin/kasir, mengubah
  toko atau status). Superadmin dibuat lewat skrip `create-superadmin`, tidak
  dari aplikasi. Akun login baru dibuat aplikasi lewat app Firebase kedua agar
  sesi superadmin tidak berganti.
- Menonaktifkan user (`isActive: false`) atau toko berlaku **seketika** di
  Security Rules: semua baca/tulis data toko ditolak pada permintaan berikutnya.
  Layar yang sedang terbuka baru menyadarinya saat aplikasi dibuka ulang atau
  token diperbarui.
- Tiap permintaan membaca dokumen user (dan dokumen toko) lewat `get()` di
  Rules; keduanya dihitung sebagai pembacaan dokumen biasa (kuota Spark 50 ribu
  per hari, cukup untuk beberapa toko).
- Aplikasi membaca `users/{uid}` saat sesi dibuka. Firestore menyimpannya di
  cache perangkat, jadi sesi tetap bisa dibuka offline setelah pernah berhasil
  masuk.
- Peran dan toko di skrip `provision`/`create-superadmin` masih ikut mengisi
  custom claims; itu tidak dipakai lagi dan tidak berbahaya.

## Menjalankan tes backend

Aturan keamanan (Firestore dan Storage), diuji di emulator:

```bash
cd firebase-tests && npm test
```

Smoke test jalur opsional Cloud Functions (hanya relevan bila memakai Blaze; aplikasi tidak bergantung padanya):

```bash
cd firebase-tests && npm run smoke
```

Logika murni Cloud Functions:

```bash
cd functions && npm test
```

## Pemecahan masalah

| Gejala | Penyebab dan solusi |
| --- | --- |
| `The current Dart SDK version is 3.13` saat `flutter pub get` | Flutter terlalu lama. Jalankan `flutter upgrade` (butuh 3.50.1). |
| Layar "Firebase belum disiapkan" | `lib/firebase_options.dart` masih placeholder. Jalankan Langkah 6, atau pakai `--dart-define=USE_EMULATOR=true` / `GALLERY=true`. |
| `CLEARTEXT communication ... not permitted` | Hanya terjadi di build release. Mode emulator hanya untuk build debug (manifest debug sudah mengizinkan HTTP). |
| Tidak bisa terhubung ke emulator dari HP fisik | Pakai `--dart-define=EMULATOR_HOST=<IP LAN komputer>`, satu Wi-Fi, dan izinkan port 9099/8080/5001 di firewall. |
| "Akun Anda belum diberi peran" | Akun login ada tetapi dokumen `users/{uid}` belum ada. Tambahkan lewat layar Toko & Pengguna (Tambah pengguna), atau lewat `provision.mjs`. |
| `permission-denied` / "Ditolak Security Rules" | Aturan di server masih versi lama: jalankan `firebase deploy --only firestore:rules` (Langkah 7). Perubahan peran/toko di dokumen `users` berlaku langsung, tanpa keluar-masuk. |
| Fungsi tidak ditemukan / salah region | Klien dan fungsi harus di `asia-southeast2` (`AppEnv.functionsRegion` dan `setGlobalOptions` di `functions/index.js`). |
| `flutterfire: command not found` | Tambahkan `~/.pub-cache/bin` ke `PATH`. |
| `firebase deploy` gagal soal Cloud Functions/Blaze | Pakai `firebase deploy --only firestore:rules,firestore:indexes`; Functions tidak dipakai di paket Spark. |

## Batasan yang diketahui

Ini keterbatasan Firestore, bukan kekeliruan konfigurasi; semuanya tercatat juga di `firestore.rules`:

- Tidak ada keamanan per field: kasir yang membaca produk juga melihat harga modal.
- Kasir menulis ringkasan harian lewat increment; rules hanya membatasi field mana
  yang boleh disentuh, bukan besar angkanya.
- Query riwayat transaksi oleh kasir wajib menyertakan `where('cashierId', '==', uid)`.
- Admin dibatasi 30 toko per akun (diperiksa di `firestore.rules`).
- User yang baru dinonaktifkan masih bisa bekerja offline sampai perangkatnya tersambung lagi; tulisan offline ditolak server saat disinkronkan.
