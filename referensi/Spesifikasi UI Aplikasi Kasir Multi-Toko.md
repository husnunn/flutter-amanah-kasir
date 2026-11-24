# Spesifikasi UI Aplikasi Kasir Multi-Toko

Nov 24, 2026 · @Niam

## Ringkasan

Kanvas [UI Aplikasi Kasir Multi-Toko](https://claude.ai/artifact/S245bgVXcUqBE3bUSscH8X) berisi 11 layar: 5 untuk tablet landscape (1280 × 800) dan 6 untuk HP portrait (390 × 844). Layar dikelompokkan dalam tiga baris: Kasir, Admin, serta Login & Superadmin. Dokumen ini mencatat apa yang tampil di setiap layar agar bisa diterjemahkan ke widget Flutter.

| Baris | Layar | Perangkat | Role |
| --- | --- | --- | --- |
| Kasir | Kasir | Tablet | Kasir, Admin |
| Kasir | Pembayaran | Tablet | Kasir, Admin |
| Kasir | Kasir | HP | Kasir, Admin |
| Kasir | Transaksi berhasil | HP | Kasir, Admin |
| Admin | Dashboard | Tablet | Admin |
| Admin | Kelola produk | Tablet | Admin |
| Admin | Dashboard | HP | Admin |
| Admin | Catat pengeluaran | HP | Admin |
| Login & Superadmin | Login | HP | Semua |
| Login & Superadmin | Pilih toko | HP | Admin |
| Login & Superadmin | Toko & pengguna | Tablet | Superadmin |

Semua nama toko, produk, harga, dan angka di desain adalah data contoh untuk mengisi tampilan.

## Fondasi visual

Satu warna aksen hijau toska tua di atas latar abu-abu muda dan kartu putih. Warna status (amber, merah, biru) hanya dipakai untuk makna tertentu.

**Warna**

| Token | Hex | Dipakai untuk |
| --- | --- | --- |
| accent | #0B7A62 | Tombol utama, menu aktif, harga, kartu saldo bersih |
| accent-dark | #075E4B | Teks di atas accent-soft, tombol di dalam bar aksen |
| accent-soft | #E6F4EF | Latar menu aktif, pilihan terpilih, kotak kembalian |
| accent-muted | #A8D8CA | Batang grafik selain hari ini |
| bg | #F4F5F7 | Latar layar |
| surface | #FFFFFF | Kartu, panel, sidebar |
| surface-alt | #F9FAFB | Header tabel, baris info dalam panel |
| border | #E4E7EC | Garis kartu, tombol sekunder |
| border-input | #D0D5DD | Garis field form |
| divider | #EEF0F3 | Pemisah antar baris |
| ink | #101828 | Teks utama, chip kategori aktif, sidebar superadmin |
| ink-2 | #344054 | Label form, teks tombol sekunder |
| ink-3 | #475467 | Teks pendukung |
| ink-4 | #5B6474 | Teks keterangan kecil, ikon nonaktif |
| warning / soft | #B54708 / #FEF3E2 | Stok menipis, toko offline |
| danger | #B42318 | Diskon, pengeluaran, tombol hapus/nonaktifkan |
| info / soft | #175CD3 / #EAF2FF | QRIS, badge Admin |

Kartu produk memakai pasangan warna lembut per kategori (latar soft + huruf tebal) sebagai pengganti foto: amber, biru, rose (#FDECEE / #C01048), violet (#F1EEFE / #5925DC), slate (#EEF0F3 / #344054), hijau.

**Tipografi:** Plus Jakarta Sans (400, 500, 600, 700, 800), angka tabular untuk semua nominal.

| Peran | Ukuran / tebal |
| --- | --- |
| Judul layar | 22 px / 700 (HP 18–24 px) |
| Angka besar (total, saldo, kembalian) | 26–30 px / 800, letter-spacing −0.02em |
| Judul kartu | 15–16 px / 700 |
| Teks isi, nama produk | 14 px / 600 |
| Label form, keterangan | 12–13 px / 500–600 |
| Label navigasi bawah | 11 px / 600–700 |

**Bentuk dan ukuran**

- Radius: 10–12 px untuk field dan tombol kecil, 14 px untuk tombol utama, 16 px untuk kartu, 20 px untuk kartu saldo dan panel besar, penuh (999 px) untuk chip.
- Tinggi tombol: utama 54–56 px, sekunder 42–48 px; area sentuh minimal 44 px.
- Jarak: kelipatan 4; padding layar 20–24 px, jarak antar kartu 12–16 px.
- Ikon: garis 1.8 px, ukuran 18–22 px, tanpa emoji.

## Peta layar

&#91;embedded content: alur layar · 3 role, 9 layar\]

Kasir berputar di alur Kasir → Pembayaran → Transaksi berhasil. Admin dengan satu toko langsung masuk ke Dashboard tanpa layar Pilih toko, dan admin juga bisa membuka layar Kasir dari menunya.

## Layar kasir

### Kasir · tablet

Tiga kolom: rail navigasi 88 px, area produk, dan panel pesanan 380 px.

- **Rail kiri:** logo, menu Kasir (aktif), Riwayat, Printer; avatar kasir dan tombol keluar di bawah.
- **Header:** tanggal dan nama kasir, nama toko, chip status "Tersinkron" dengan titik hijau.
- **Pencarian:** field "Cari nama produk atau SKU" dan tombol Scan di sebelahnya.
- **Chip kategori:** Semua (aktif, latar ink), Makanan, Minuman, Sembako, Kebersihan, Lainnya.
- **Grid produk:** 4 kolom. Setiap kartu berisi blok inisial berwarna, nama (satu baris, terpotong), harga hijau, dan stok. Stok menipis tampil amber ("Sisa 3"). Produk yang sudah di keranjang mendapat garis hijau dan badge jumlah di pojok kanan atas.
- **Panel pesanan:** judul "Pesanan" dengan jumlah produk dan item, tombol Kosongkan (merah). Setiap item menampilkan nama, subtotal, harga satuan, dan stepper −/+. Bagian bawah berisi Subtotal, Diskon (tautan untuk menambah), Total besar, lalu tombol "Bayar Rp 58.500".

### Pembayaran · tablet

- **Header:** tombol kembali, judul "Pembayaran", nomor nota (TK01-20261124-121506-A3).
- **Kiri (400 px):** ringkasan pesanan (qty × nama, subtotal), Subtotal, Diskon, Total tagihan.
- **Kanan:** tiga pilihan metode (Tunai terpilih, QRIS, Transfer) sebagai kartu radio; field "Uang diterima" besar; tombol nominal cepat (Uang pas, Rp 60.000, Rp 70.000, Rp 100.000); kotak Kembalian hijau; papan angka 3 × 4 (1–9, 000, 0, hapus).
- **Bawah:** Batal (sekunder) dan "Selesaikan & cetak nota" (utama).

### Kasir · HP

- **Header:** nama toko, kasir, status sinkron, tombol printer.
- **Pencarian:** field dengan tombol scan di dalamnya, lalu chip kategori yang bisa digeser.
- **Daftar produk:** baris dengan inisial 48 px, nama, harga, stok. Produk di keranjang menampilkan stepper; yang belum menampilkan tombol +.
- **Bar pesanan** (hijau, menempel di atas navigasi): "12 item · 4 produk", total, tombol "Lihat pesanan".
- **Navigasi bawah:** Kasir, Riwayat, Akun.

### Transaksi berhasil · HP

- Ikon centang hijau, judul "Transaksi berhasil", ringkasan nominal, metode, dan kembalian.
- **Pratinjau nota:** nama toko, alamat dan telepon (placeholder), nomor nota, waktu, kasir, metode, daftar item, diskon, total, bayar/kembali, ucapan terima kasih. Pemisah garis putus-putus.
- Status "Nota tercetak · Printer 58 mm terhubung".
- Tombol Cetak ulang dan Kirim WhatsApp (berdampingan), lalu tombol utama "Transaksi baru".

## Layar admin

### Dashboard · tablet

- **Sidebar 240 px:** logo, pemilih toko aktif ("Toko aktif · 3 toko", nama toko, ikon panah atas-bawah), menu Dashboard (aktif), Kasir, Produk, Pengeluaran, Laporan, Riwayat transaksi, Kasir & shift, Pengaturan toko; profil admin di bawah.
- **Header:** judul, rentang tanggal dan nama toko, segmented control periode (Hari, Minggu, Bulan terpilih, Tahun).
- **4 kartu angka:** Saldo kotor (+ jumlah transaksi), Laba kotor ("Penjualan − HPP"), Pengeluaran (angka merah), Saldo bersih (kartu hijau penuh, "Laba kotor − pengeluaran").
- **Grafik pendapatan harian:** batang per hari 1–24 November, hari ini berwarna accent, sisanya accent-muted; sumbu Y dalam juta, label X di tanggal 1, 5, 10, 15, 20, 24. Di bawahnya bar bertumpuk per metode bayar (Tunai, QRIS, Transfer) dengan legenda persen dan nominal.
- **Kolom kanan 320 px:** Produk terlaris (5 produk, jumlah terjual, bar progres) dan Stok menipis (badge "3 produk", sisa / minimum dalam amber).

### Kelola produk · tablet

- Sidebar sama dengan dashboard, menu Produk aktif.
- **Header:** "Produk", jumlah produk dan kategori, tombol Kategori dan "Tambah produk".
- **Filter:** pencarian "Cari nama, SKU, atau barcode", dropdown Semua kategori, tombol amber "Stok menipis · 3".
- **Tabel:** kolom Produk (inisial, nama, SKU atau barcode), Kategori, Harga jual, Stok. Baris terpilih berlatar hijau sangat muda; stok menipis berwarna amber.
- **Panel edit 340 px:** Nama produk; Kategori dan Satuan; Harga jual dan Harga modal; Stok dan Stok minimum; Barcode (opsional) dengan tombol scan; baris margin per item dan centang Aktif; tombol Nonaktifkan (merah) dan "Simpan perubahan".

### Dashboard · HP

- Tombol pemilih toko di kiri atas (menuju layar Pilih toko), avatar di kanan.
- Segmented control periode, Minggu terpilih.
- **Kartu saldo hijau:** Saldo bersih besar, lalu Saldo kotor dan Pengeluaran dalam dua kolom.
- **Grafik 7 hari** (Rab–Sel) dengan nilai dalam ribu Rp di atas batang; hari ini accent.
- **Peringatan amber:** "3 produk hampir habis" dengan nama produk.
- **3 aksi cepat:** Tambah produk, Pengeluaran, Laporan.
- **Navigasi bawah:** Beranda, Kasir, Produk, Laporan, Lainnya.

### Catat pengeluaran · HP

- Tombol kembali, judul, nama toko.
- Field Nominal besar.
- Kategori sebagai grid tombol 3 kolom: Belanja stok (terpilih), Listrik & air, Gaji, Sewa, Transportasi, Lainnya.
- Field Tanggal dengan ikon kalender, field Keterangan (3 baris).
- Kotak unggah garis putus-putus "Foto bukti / nota · Opsional".
- Tombol utama "Simpan pengeluaran" di bawah.

## Login, pilih toko, dan superadmin

### Login · HP

- **Bagian atas hijau (300 px):** logo putih, judul "Kasir untuk semua toko Anda", satu kalimat penjelasan.
- **Lembar putih membulat** yang menumpuk 28 px di atas bagian hijau: judul "Masuk", field Email dan Password (ikon di kiri, tombol tampilkan password), tautan "Lupa password?", tombol Masuk.
- Catatan di bawah: akun dibuat oleh pengelola aplikasi. Tidak ada tombol daftar.

### Pilih toko · HP

Muncul setelah login untuk admin yang mengelola lebih dari satu toko.

- Sapaan, judul "Pilih toko", keterangan jumlah toko dan bahwa toko aktif bisa diganti dari dashboard.
- Pencarian toko.
- **Kartu toko** sebagai pilihan radio: kode toko berwarna, nama, kota, jumlah kasir, penjualan hari ini, status sinkron (hijau "Tersinkron" atau amber "Offline sejak 09.40"). Kartu terpilih bergaris hijau 2 px.
- Tombol utama "Masuk ke \[nama toko\]".

### Toko & pengguna · tablet (superadmin)

- **Sidebar gelap** (ink) dengan badge "SUPERADMIN", untuk membedakan dari tampilan admin. Menu: Ringkasan, Toko (aktif), Pengguna, Pengaturan aplikasi.
- **Header:** "Toko" dan tombol "Tambah toko".
- **3 kartu angka:** Toko aktif (7 dari 8), Admin, Kasir.
- **Tabel toko:** kode, nama dan kota, admin, jumlah kasir, badge status (Aktif hijau, Nonaktif abu-abu).
- **Panel detail 340 px:** kode dan nama toko, tanggal dibuat, sakelar "Toko aktif", info scan barcode dan transaksi bulan ini, daftar pengguna di toko itu (inisial, nama, catatan seperti "Juga mengelola TK02, TK03" atau shift, badge role Admin biru / Kasir abu-abu), tombol "Tambah pengguna", tombol "Edit data toko".

## Komponen berulang

Sembilan komponen ini muncul di lebih dari satu layar dan layak dibuat sebagai widget tersendiri.

| Komponen | Tampilan | Dipakai di |
| --- | --- | --- |
| NavRail | Lebar 88 px, ikon + label 11 px, item aktif berlatar accent-soft | Kasir tablet |
| AdminSidebar | Lebar 240 px, pemilih toko di atas, item 42 px, profil di bawah; varian gelap untuk superadmin | Dashboard, Produk, Superadmin |
| BottomNav | Tinggi 68 px, 3–5 item ikon + label | Kasir HP, Dashboard HP |
| StorePicker | Kotak bergaris, label "Toko aktif", nama toko tebal, ikon panah | Sidebar admin, Dashboard HP |
| CategoryChip | Tinggi 34–38 px, radius penuh; aktif = latar ink, teks putih | Kasir tablet dan HP |
| ProductTile | Blok inisial berwarna + nama + harga + stok; badge jumlah dan garis hijau bila di keranjang | Kasir tablet (kartu), Kasir HP (baris), tabel Produk |
| QtyStepper | Tombol − abu-abu, angka tebal, tombol + hijau muda, masing-masing 30–32 px | Panel pesanan, Kasir HP |
| StatCard | Label 13 px, angka 22 px / 800, keterangan 12 px; varian hijau penuh untuk saldo bersih | Dashboard tablet dan HP, Superadmin |
| StatusBadge | Pil kecil: hijau (Aktif, Tersinkron), amber (stok menipis, offline), abu-abu (Nonaktif), biru (Admin) | Banyak layar |

**Tombol**

- **Utama:** latar accent, teks putih 16 px / 700, tinggi 54–56 px, radius 14 px.
- **Sekunder:** latar putih, garis border, teks ink-2 600.
- **Destruktif:** latar putih, garis merah muda, teks danger.
- **Pilihan terpilih** (metode bayar, kategori pengeluaran): garis accent 1.5–2 px, latar accent-soft, teks accent-dark.

## Catatan implementasi Flutter

**Tema.** Taruh token warna di `ColorScheme` + `ThemeExtension` agar warna status (warning, info, accent-muted) ikut terbawa:

```dart
final theme = ThemeData(
  useMaterial3: true,
  fontFamily: 'PlusJakartaSans',
  scaffoldBackgroundColor: const Color(0xFFF4F5F7),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0B7A62),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE6F4EF),
    onPrimaryContainer: Color(0xFF075E4B),
    surface: Colors.white,
    onSurface: Color(0xFF101828),
    outline: Color(0xFFE4E7EC),
    error: Color(0xFFB42318),
  ),
);
```

**Breakpoint.** Pakai `LayoutBuilder`: lebar 900 dp ke atas memakai layout tablet (rail/sidebar + panel samping), di bawahnya layout HP (navigasi bawah, keranjang di halaman/bottom sheet terpisah).

**Angka.** Aktifkan `FontFeature.tabularFigures()` untuk semua nominal agar angka tidak bergeser saat berubah. Format Rupiah dengan `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)`.

**Grafik.** Batang pendapatan bisa dibuat dengan `fl_chart` (BarChart), warna batang hari ini `primary`, sisanya `#A8D8CA`.

**Belum ada di desain**

- [ ] Halaman "Lihat pesanan" (keranjang) dan pembayaran versi HP
- [ ] Riwayat transaksi dan alur void
- [ ] Laporan mingguan dan export
- [ ] Kelola kategori, pengaturan toko, dan pengaturan printer
- [ ] Form tambah toko dan tambah pengguna (superadmin)
- [ ] Status kosong, loading, error, dan mode offline penuh
- [ ] Dark mode
