// Mengisi Firebase Emulator dengan data demo agar semua jalur login bisa dicoba.
//
//   firebase emulators:start --project demo-amanah-kasir
//   FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 \
//   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 \
//   node functions/scripts/seed-emulator.mjs
//
// Skrip MENOLAK berjalan bila host emulator tidak diset, supaya tidak pernah
// menulis data demo ke project produksi.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
const { syncUserAccess } = require('../src/access.js');

export const PROJECT_ID = 'demo-amanah-kasir';
export const DEMO_PASSWORD = 'Password123!';

export const stores = [
  { id: 'tk01', code: 'TK01', name: 'Toko Berkah Jaya', city: 'Surabaya', isActive: true },
  { id: 'tk02', code: 'TK02', name: 'Warung Bu Sri', city: 'Sidoarjo', isActive: true },
  { id: 'tk03', code: 'TK03', name: 'Kios Sembako Makmur', city: 'Gresik', isActive: false },
];

/** key = uid. Setiap akun mewakili satu skenario login. */
export const users = [
  { key: 'superadmin', email: 'superadmin@amanah.test', name: 'Pemilik Aplikasi', role: 'superadmin', storeIds: [] },
  { key: 'admin', email: 'admin@amanah.test', name: 'Sari Ayu', role: 'admin', storeIds: ['tk01', 'tk02', 'tk03'] },
  { key: 'admin1', email: 'admin1@amanah.test', name: 'Hendra', role: 'admin', storeIds: ['tk01'] },
  { key: 'kasir', email: 'kasir@amanah.test', name: 'Rina Wati', role: 'kasir', storeIds: ['tk01'] },
  { key: 'kasirNonaktif', email: 'kasir.nonaktif@amanah.test', name: 'Budi (nonaktif)', role: 'kasir', storeIds: ['tk01'], isActive: false },
  { key: 'kasirTokoNonaktif', email: 'kasir.tokonon@amanah.test', name: 'Dewi', role: 'kasir', storeIds: ['tk03'] },
];

/** Akun Auth tanpa dokumen/peran (lupa diberi peran). */
export const noRoleUser = { key: 'tanpaperan', email: 'tanpaperan@amanah.test', name: 'Tanpa Peran' };

const products = [
  ['Mi Instan Goreng', 'SKU-0012', 'Makanan', 3500, 2800, 120],
  ['Air Mineral 600 ml', 'SKU-0031', 'Minuman', 4000, 3000, 86],
  ['Beras Premium 5 kg', 'SKU-0101', 'Sembako', 74000, 68000, 12],
  ['Minyak Goreng 1 L', 'SKU-0104', 'Sembako', 18500, 16500, 6],
  ['Telur Ayam 1 kg', 'SKU-0108', 'Sembako', 28000, 24500, 3],
  ['Kopi Sachet', 'SKU-0033', 'Minuman', 1500, 1100, 200],
];

export async function seedAll({ auth, db }) {
  // Toko
  for (const s of stores) {
    await db.doc(`stores/${s.id}`).set({
      code: s.code,
      name: s.name,
      address: `Jl. Contoh No. 1, ${s.city}`,
      phone: '081234567890',
      receiptHeader: s.name,
      receiptFooter: 'Terima kasih atas kunjungan Anda',
      taxPercent: 0,
      scanEnabled: true,
      isActive: s.isActive,
      createdAt: FieldValue.serverTimestamp(),
    });
    await db.doc(`store_codes/${s.code}`).set({ storeId: s.id, createdAt: FieldValue.serverTimestamp() });
  }

  // Kategori + produk contoh untuk toko pertama
  const categories = ['Makanan', 'Minuman', 'Sembako'];
  for (const [i, name] of categories.entries()) {
    await db.doc(`stores/tk01/categories/${name.toLowerCase()}`).set({ name, sortOrder: i });
  }
  for (const [i, [name, sku, category, price, costPrice, stock]] of products.entries()) {
    await db.doc(`stores/tk01/products/p${i + 1}`).set({
      categoryId: category.toLowerCase(),
      name, sku, barcode: null, price, costPrice, stock,
      minStock: 10, unit: 'pcs', imageUrl: null, isActive: true,
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  // Pengguna: hapus bila sudah ada supaya hasilnya selalu sama.
  const all = [...users, noRoleUser];
  for (const u of all) {
    try { await auth.deleteUser(u.key); } catch { /* belum ada */ }
    await auth.createUser({ uid: u.key, email: u.email, password: DEMO_PASSWORD, displayName: u.name });
  }
  for (const u of users) {
    await db.doc(`users/${u.key}`).set({
      name: u.name,
      email: u.email,
      role: u.role,
      storeIds: u.storeIds,
      isActive: u.isActive ?? true,
      createdAt: FieldValue.serverTimestamp(),
    });
    await syncUserAccess({ auth, db }, u.key);
  }
}

function requireEmulator() {
  if (!process.env.FIREBASE_AUTH_EMULATOR_HOST || !process.env.FIRESTORE_EMULATOR_HOST) {
    console.error(
      'Menolak berjalan: FIREBASE_AUTH_EMULATOR_HOST dan FIRESTORE_EMULATOR_HOST belum diset.\n' +
      'Skrip ini hanya untuk Firebase Emulator, bukan project asli.',
    );
    process.exit(1);
  }
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  requireEmulator();
  const app = initializeApp({ projectId: process.env.GCLOUD_PROJECT || PROJECT_ID });
  await seedAll({ auth: getAuth(app), db: getFirestore(app) });
  console.log(`Seed selesai. Semua akun memakai password: ${DEMO_PASSWORD}`);
  for (const u of [...users, noRoleUser]) console.log(`  ${u.email.padEnd(30)} ${u.role ?? '(tanpa peran)'}`);
}
