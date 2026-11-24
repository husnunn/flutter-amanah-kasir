# PRD & ERD Aplikasi Kasir Multi-Toko

Nov 24, 2026 · @Niam

## Ringkasan produk

Aplikasi kasir (POS) berbasis mobile untuk banyak toko sekaligus, dari toko ritel hingga pedagang UMKM, dibangun dengan Flutter dan Firebase. Satu aplikasi melayani tiga peran: kasir mencatat penjualan dan mencetak nota, admin mengelola produk dan keuangan toko, superadmin mengelola toko dan pengguna di seluruh platform.

**Tujuan**

- Kasir bisa menyelesaikan satu transaksi (pilih produk, bayar, cetak nota) dalam waktu singkat, termasuk saat internet putus.
- Admin bisa melihat saldo kotor, saldo bersih, dan grafik pendapatan tanpa menghitung manual.
- Superadmin bisa menambah toko baru dan penggunanya tanpa menyentuh database secara langsung.

**Asumsi awal** (sudah dikonfirmasi, kecuali yang masih ada di Pertanyaan terbuka)

- Superadmin = pemilik platform. Setiap toko adalah tenant terpisah, datanya tidak saling terlihat.
- Satu superadmin mengelola seluruh aplikasi. Satu admin bisa mengelola banyak toko. Satu toko bisa punya banyak kasir, dan setiap kasir terikat ke satu toko.
- Firebase berperan sebagai backend: Auth, Firestore, Cloud Functions, Storage. Tidak ada server terpisah.
- Mata uang Rupiah, zona waktu WIB (Asia/Jakarta) untuk laporan harian.

**Di luar cakupan versi 1:** pembayaran QRIS terintegrasi otomatis (cukup dicatat sebagai metode bayar), program member/poin, pembelian ke supplier, dan aplikasi pelanggan.

## Role dan hak akses

Ada tiga role. Kasir hanya bisa mengakses satu toko tempat ia terdaftar, dan satu toko bisa punya banyak kasir. Admin bisa mengelola beberapa toko dan berpindah toko aktif lewat pemilih toko. Superadmin mengelola seluruh aplikasi dan semua toko.

| Fitur | Kasir | Admin | Superadmin |
| --- | --- | --- | --- |
| Catat pesanan / transaksi | Ya | Ya | - |
| Cetak dan kirim ulang nota | Ya | Ya | - |
| Scan barcode/QR saat transaksi (opsional) | Ya | Ya | - |
| Lihat riwayat transaksi | Milik sendiri, hari ini | Semua | Semua (baca saja) |
| Batalkan (void) transaksi | Ajukan | Setujui | - |
| Tambah, edit, hapus produk (scan barcode opsional) | - | Ya | - |
| Catat pengeluaran | - | Ya | - |
| Saldo kotor, saldo bersih, grafik, laporan | - | Ya | Semua toko |
| Pengaturan toko (header nota, printer, pajak) | - | Ya | Ya |
| Kelola kasir di toko yang dikelola | - | Opsional | Ya |
| Tambah, edit, hapus user semua role | - | - | Ya |
| Tambah, nonaktifkan toko | - | - | Ya |
| Pilih toko aktif dan lihat laporan gabungan | - | Toko yang dikelola | Semua toko |

Role dan akses toko disimpan di Firebase Auth custom claims (`role`, `storeIds`) agar bisa diperiksa langsung oleh Security Rules. Kasir punya tepat satu toko di `storeIds`, admin bisa beberapa, superadmin tidak perlu. Custom claims dibatasi 1.000 byte, cukup untuk sekitar 30 toko per admin; jika lebih, rules memeriksa dokumen keanggotaan dengan `get()`. Dokumen `users` tetap menyimpan salinan untuk ditampilkan di aplikasi.

## Kebutuhan fungsional

Prioritas: **P1** wajib ada di MVP, **P2** di rilis berikutnya, **P3** opsional.

| ID | Modul | Kebutuhan | Role | Prioritas |
| --- | --- | --- | --- | --- |
| F-01 | Autentikasi | Login email + password, logout, lupa password | Semua | P1 |
| F-02 | Autentikasi | Arahkan ke tampilan sesuai role setelah login; admin dengan lebih dari satu toko memilih toko aktif (bisa diganti kapan saja); tolak user/toko yang nonaktif | Semua | P1 |
| F-03 | Kasir | Cari produk (nama/kategori) atau pilih dari grid. Scan barcode/QR (kamera / scanner eksternal) hanya muncul jika diaktifkan di pengaturan toko | Kasir, Admin | P1 |
| F-04 | Kasir | Keranjang: ubah qty, hapus item, diskon per item atau per nota | Kasir, Admin | P1 |
| F-05 | Kasir | Pembayaran: tunai (hitung kembalian), QRIS, transfer, dicatat sebagai metode bayar | Kasir, Admin | P1 |
| F-06 | Kasir | Simpan transaksi, kurangi stok, beri nomor nota unik | Kasir, Admin | P1 |
| F-07 | Kasir | Cetak nota ke printer thermal Bluetooth 58/80 mm (ESC/POS) | Kasir, Admin | P1 |
| F-08 | Kasir | Kirim nota sebagai PDF/gambar lewat WhatsApp (cadangan bila printer bermasalah) | Kasir, Admin | P2 |
| F-09 | Kasir | Riwayat transaksi dan cetak ulang nota | Kasir, Admin | P1 |
| F-10 | Kasir | Ajukan void transaksi dengan alasan; admin menyetujui, stok dikembalikan | Kasir, Admin | P2 |
| F-11 | Kasir | Buka/tutup shift: modal awal laci, rekap tunai di akhir shift | Kasir, Admin | P3 |
| F-12 | Produk | Tambah/edit/hapus produk: nama, SKU, barcode (opsional), kategori, harga jual, harga modal, stok, satuan, foto | Admin | P1 |
| F-13 | Produk | Opsional: scan barcode/QR untuk mengisi field barcode saat input produk | Admin | P2 |
| F-14 | Produk | Kelola kategori produk | Admin | P1 |
| F-15 | Produk | Penyesuaian stok (stok masuk, rusak, opname) dengan catatan | Admin | P2 |
| F-16 | Produk | Peringatan stok di bawah batas minimum | Admin | P2 |
| F-17 | Keuangan | Catat pengeluaran: tanggal, kategori, nominal, keterangan, foto bukti | Admin | P1 |
| F-18 | Keuangan | Saldo kotor (total penjualan) dan saldo bersih (penjualan - HPP - pengeluaran) per periode | Admin | P1 |
| F-19 | Laporan | Grafik pendapatan per hari, minggu, bulan, tahun | Admin | P1 |
| F-20 | Laporan | Laporan mingguan: penjualan, pengeluaran, laba, produk terlaris, per metode bayar | Admin | P1 |
| F-21 | Laporan | Export laporan ke PDF/Excel | Admin | P2 |
| F-22 | Pengaturan | Profil toko dan header/footer nota, pilih printer, pajak (opsional), aktif/nonaktif scan barcode | Admin | P1 |
| F-23 | Superadmin | Tambah, edit, nonaktifkan toko | Superadmin | P1 |
| F-24 | Superadmin | Tambah, edit, hapus/nonaktifkan user, atur role, dan tetapkan toko (kasir 1 toko, admin bisa banyak toko) | Superadmin | P1 |
| F-25 | Superadmin | Ringkasan penjualan semua toko | Superadmin | P2 |
| F-26 | Audit | Log aktivitas penting (hapus produk, ubah harga, void) | Admin, Superadmin | P3 |
| F-27 | Multi-toko | Ringkasan penjualan dan laba gabungan semua toko yang dikelola admin, plus perbandingan antar toko | Admin | P2 |

"Update data" pada daftar awal tercakup di F-12, F-15, dan F-17: setiap data yang bisa dibuat juga bisa diedit oleh role yang berwenang.

## Kebutuhan non-fungsional

| Aspek | Kebutuhan |
| --- | --- |
| Offline | Transaksi, cetak nota, dan riwayat hari ini tetap jalan tanpa internet; data tersinkron otomatis saat online. Pakai offline persistence Firestore dan batch write + `FieldValue.increment()`, bukan Firestore transaction (tidak jalan offline). |
| Nomor nota | Unik tanpa perlu server: `{kodeToko}-{yyyyMMdd}-{HHmmss}-{kodePerangkat}`, misalnya `TK01-20261124-120615-A3`. |
| Responsive | Tablet landscape: grid produk kiri + keranjang kanan. HP portrait: daftar produk penuh + keranjang di bottom sheet. Breakpoint lewat `LayoutBuilder`, misalnya lebar di atas 900 dp = tablet. |
| Keamanan | Security Rules memeriksa `request.auth.token.role` dan memastikan `storeId` di path ada di `token.storeIds`. User nonaktif ditolak (claims dicabut + refresh token di-revoke). |
| Integritas data | Item transaksi menyimpan salinan nama, harga jual, dan harga modal saat transaksi, sehingga laporan lama tidak berubah saat harga produk diedit. |
| Performa & biaya | Grafik dan laporan membaca dokumen ringkasan harian, bukan semua transaksi. Daftar produk dan riwayat memakai paginasi. |
| Perangkat | Android 8+ (HP dan tablet). Printer thermal Bluetooth ESC/POS 58 mm dan 80 mm. Kamera scan dan scanner barcode eksternal (mode keyboard HID) bersifat opsional; aplikasi tetap bisa dipakai penuh tanpa keduanya, cocok untuk UMKM yang produknya tidak berbarcode. |
| Bahasa & format | Bahasa Indonesia, Rupiah tanpa desimal, tanggal dd/MM/yyyy, zona waktu Asia/Jakarta. |

## Alur transaksi kasir

Satu transaksi selalu ditulis dalam satu batch, sehingga transaksi, pengurangan stok, dan ringkasan harian berhasil semua atau gagal semua.

1. Kasir login dan masuk ke layar kasir tokonya.
2. Kasir menambah item ke keranjang lewat grid produk atau pencarian, atau lewat scan barcode jika fitur itu diaktifkan.
3. Kasir mengatur qty dan diskon, lalu menekan Bayar.
4. Kasir memilih metode bayar. Untuk tunai, kasir memasukkan uang diterima dan aplikasi menghitung kembalian.
5. Aplikasi membuat nomor nota dan menulis satu batch:
   1. dokumen transaksi + item (dengan salinan harga jual dan harga modal),
   2. `stock: increment(-qty)` untuk setiap produk,
   3. `daily_summaries/{tanggal}`: increment omzet, HPP, jumlah transaksi, dan total per metode bayar.
6. Nota dicetak ke printer Bluetooth. Jika printer gagal, kasir bisa mengirim nota sebagai PDF atau mencetak ulang dari riwayat.
7. Jika sedang offline, batch tersimpan di perangkat dan dikirim otomatis saat internet kembali. Layar menampilkan tanda "belum tersinkron".

Void: kasir mengajukan dengan alasan, admin menyetujui, lalu satu batch mengubah status transaksi menjadi `void`, mengembalikan stok, dan mengurangi ringkasan harian.

## ERD

&#91;embedded content: ERD aplikasi kasir · 11 entitas\]

Store memiliki semua subkoleksi, sedangkan User berada di level atas dan terhubung ke Store lewat storeId. Transaction adalah entitas inti: menyimpan item sebagai array, mencatat kasir (User) dan Shift, lalu bersama Expense mengisi DailySummary yang menjadi sumber grafik dan laporan.

## Kamus data dan struktur Firestore

Semua data operasional berada di bawah `stores/{storeId}`, sehingga Security Rules cukup memeriksa apakah `storeId` di path ada di daftar `storeIds` milik user. Hanya `users` yang berada di level atas karena superadmin mengelola semua user dan satu admin bisa terhubung ke banyak toko.

| Entitas | Path Firestore | Field utama | Catatan |
| --- | --- | --- | --- |
| Store | `stores/{storeId}` | code, name, address, phone, receiptHeader, receiptFooter, taxPercent, scanEnabled, isActive, createdAt | `code` dipakai di nomor nota (TK01) |
| User | `users/{uid}` | storeIds\[\], name, email, role (`superadmin`/`admin`/`kasir`), isActive, createdAt | `uid` = UID Firebase Auth; kasir: tepat 1 toko; admin: 1 toko atau lebih; superadmin: kosong |
| Category | `stores/{id}/categories/{categoryId}` | name, sortOrder |  |
| Product | `stores/{id}/products/{productId}` | categoryId, name, sku, barcode, price, costPrice, stock, minStock, unit, imageUrl, isActive, updatedAt | barcode opsional, jika diisi harus unik per toko; hapus = `isActive: false` agar riwayat aman |
| Transaction | `stores/{id}/transactions/{trxId}` | receiptNo, cashierId, cashierName, items\[\], subtotal, discount, tax, total, totalCost, paymentMethod, amountPaid, change, status (`paid`/`void`), voidReason, voidBy, deviceId, shiftId, createdAt | items disimpan sebagai array di dokumen agar satu nota = satu read |
| TransactionItem | array `items` di Transaction | productId, name, barcode, qty, price, costPrice, discount, subtotal | salinan harga saat transaksi |
| Expense | `stores/{id}/expenses/{expenseId}` | date, category, amount, note, proofUrl, createdBy, createdAt | foto bukti di Firebase Storage |
| DailySummary | `stores/{id}/daily_summaries/{yyyy-MM-dd}` | date, grossSales, totalCost, totalExpense, discount, txCount, voidCount, byPayment {cash, qris, transfer} | diisi dengan increment; sumber grafik dan laporan |
| StockMovement | `stores/{id}/stock_movements/{moveId}` | productId, type (`sale`/`in`/`adjust`/`void`), qty, note, refId, createdBy, createdAt | P2, jejak perubahan stok |
| Shift | `stores/{id}/shifts/{shiftId}` | cashierId, openedAt, closedAt, openingCash, closingCash, expectedCash | P3 |
| ActivityLog | `stores/{id}/activity_logs/{logId}` | userId, action, targetType, targetId, before, after, createdAt | P3, ditulis Cloud Functions |

**Rumus laporan** (dihitung dari DailySummary pada rentang tanggal):

- Saldo kotor = jumlah `grossSales`
- Laba kotor = `grossSales` - `totalCost`
- Saldo bersih = `grossSales` - `totalCost` - `totalExpense`

Produk terlaris di laporan mingguan dihitung dari transaksi minggu itu, atau dibuat sekali seminggu oleh scheduled Cloud Function ke `weekly_reports/{yyyy-Www}` agar tidak dihitung ulang setiap kali dibuka.

## Arsitektur dan backend

Tidak perlu server backend terpisah (Laravel, Node/Express, dll). Firebase berperan sebagai backend, ditambah beberapa Cloud Functions untuk pekerjaan yang tidak boleh dilakukan dari aplikasi.

| Bagian | Ditangani oleh | Alasan |
| --- | --- | --- |
| Login, sesi | Firebase Auth | Bawaan |
| CRUD produk, transaksi, pengeluaran | Aplikasi Flutter langsung ke Firestore | Cepat, bisa offline; diamankan Security Rules |
| Foto produk, bukti pengeluaran | Firebase Storage | Bawaan; rules per `storeId` |
| Tambah/edit/hapus user, set role + toko | Cloud Function callable (Admin SDK) | Client SDK akan me-logout superadmin; custom claims hanya bisa diset Admin SDK |
| Nonaktifkan user/toko | Cloud Function callable | Mencabut claims dan revoke refresh token |
| Laporan mingguan, produk terlaris | Scheduled Cloud Function (P2) | Dihitung sekali, dibaca berkali-kali |
| Log aktivitas | Firestore trigger Cloud Function (P3) | Tidak bisa dipalsukan dari aplikasi |

**Konsekuensi biaya:** Cloud Functions butuh paket Blaze (bayar sesuai pemakaian). Untuk skala awal beberapa toko, pemakaian biasanya masih di dalam kuota gratis, tapi pasang budget alert di Google Cloud.

**Security Rules (garis besar)**

- `users/{uid}`: baca diri sendiri; tulis hanya lewat Cloud Function.
- `stores/{storeId}/**`: baca/tulis jika `storeId in token.storeIds` atau `token.role == 'superadmin'`.
- `products`, `expenses`, `categories`: tulis hanya `admin`.
- `transactions`: `kasir` boleh membuat; ubah status ke `void` hanya `admin`.

**Struktur Flutter yang disarankan:** state management Riverpod atau Bloc, folder per fitur (`auth`, `kasir`, `produk`, `keuangan`, `laporan`, `superadmin`), repository layer di atas Firestore. Paket: `cloud_firestore`, `firebase_auth`, `cloud_functions`, `mobile_scanner`, `print_bluetooth_thermal` + `esc_pos_utils_plus`, `fl_chart`, `pdf`.

## Roadmap dan pertanyaan terbuka

Pengerjaan dibagi tiga fase. Setiap fase berakhir dengan aplikasi yang bisa dicoba di toko.

1. **Fase 1, MVP kasir:** setup Firebase + Security Rules, login + role, Cloud Function kelola user, CRUD kategori dan produk, layar kasir responsive, pembayaran, cetak nota Bluetooth, riwayat transaksi, uji offline. (F-01 s.d. F-07, F-09, F-12, F-14, F-22 s.d. F-24)
2. **Fase 2, keuangan dan laporan:** pengeluaran, DailySummary, saldo kotor/bersih, grafik hari/minggu/bulan/tahun, laporan mingguan, void, scan barcode/QR (opsional), nota via WhatsApp, stok minimum, export PDF/Excel. (F-08, F-10, F-13, F-15 s.d. F-21, F-25)
3. **Fase 3, penyempurnaan:** shift kasir, log aktivitas, ringkasan lintas toko yang lebih lengkap. (F-11, F-26)

**Pertanyaan terbuka**

- [ ] Apakah admin boleh menambah kasir sendiri, atau hanya superadmin?
- [ ] Apakah ada pajak (PPN) atau service charge yang perlu tampil di nota?
- [ ] Printer thermal yang akan dipakai: merek dan ukuran kertas (58 atau 80 mm)?
- [ ] Apakah toko akan ditagih biaya langganan? Jika ya, perlu field masa aktif di Store.
- [ ] Perlu dukungan iOS/iPad, atau Android saja?
