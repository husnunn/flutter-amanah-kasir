import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { Timestamp, doc, setDoc } from 'firebase/firestore';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

export const PROJECT_ID = 'demo-amanah-kasir';

/**
 * Membuat test environment hanya untuk layanan yang dipakai berkas tes itu.
 * Tiap berkas tes berjalan di proses sendiri; bila keduanya mengirim aturan ke
 * kedua emulator, penggantian set aturan oleh satu proses bisa mengganggu proses
 * lain (tes Storage jadi sesekali gagal di hook).
 */
export function createEnv({ firestore = false, storage = false } = {}) {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    ...(firestore && {
      firestore: { rules: readFileSync(resolve(root, 'firestore.rules'), 'utf8') },
    }),
    ...(storage && {
      storage: { rules: readFileSync(resolve(root, 'storage.rules'), 'utf8') },
    }),
  });
}

/**
 * Persona = uid (+ custom claims). Firestore Rules TIDAK memakai claims: peran
 * dibaca dari dokumen users/{uid} (lihat `seed`). Claims tetap dikirim untuk
 * Storage Rules, dan untuk membuktikan bahwa claims palsu diabaikan Firestore.
 */
export const personas = {
  superadmin: { uid: 'su', claims: { role: 'superadmin', storeIds: [] } },
  admin: { uid: 'ad1', claims: { role: 'admin', storeIds: ['s1', 's2'] } },
  adminOther: { uid: 'ad3', claims: { role: 'admin', storeIds: ['s3'] } },
  kasir: { uid: 'k1', claims: { role: 'kasir', storeIds: ['s1'] } },
  kasirB: { uid: 'k2', claims: { role: 'kasir', storeIds: ['s1'] } },
  // Akun tanpa dokumen users/{uid}.
  noRole: { uid: 'x1', claims: {} },
  // Dokumen user bilang kasir s1, tetapi token mengaku superadmin.
  kasirForgedClaims: { uid: 'k1', claims: { role: 'superadmin', storeIds: [] } },
  // Token mengaku superadmin, tetapi tidak punya dokumen users/{uid}.
  forgedNoDoc: { uid: 'forged', claims: { role: 'superadmin', storeIds: [] } },
  // Dokumen user isActive:false.
  kasirInactive: { uid: 'kx', claims: { role: 'kasir', storeIds: ['s1'] } },
  // Kasir di toko yang dinonaktifkan (s4).
  kasirStoreOff: { uid: 'k4', claims: { role: 'kasir', storeIds: ['s4'] } },
};

const ctx = (env, name) =>
  env.authenticatedContext(personas[name].uid, personas[name].claims);

export const fs = (env, name) => ctx(env, name).firestore();
export const storage = (env, name) => ctx(env, name).storage();
export const anonFs = (env) => env.unauthenticatedContext().firestore();

/** Data awal (ditulis dengan rules dimatikan). */
export async function seed(env) {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (admin) => {
    const db = admin.firestore();
    const put = (path, data) => setDoc(doc(db, path), data);

    const user = (name, role, storeIds, isActive = true) => ({
      name,
      email: `${name.toLowerCase()}@contoh.com`,
      role,
      storeIds,
      isActive,
      createdAt: Timestamp.fromDate(new Date('2026-11-01T00:00:00Z')),
    });
    await put('users/su', user('Su', 'superadmin', []));
    await put('users/ad1', user('Ad1', 'admin', ['s1', 's2']));
    await put('users/ad3', user('Ad3', 'admin', ['s3']));
    await put('users/k1', user('K1', 'kasir', ['s1']));
    await put('users/k2', user('K2', 'kasir', ['s1']));
    await put('users/kx', user('Kx', 'kasir', ['s1'], false));
    await put('users/k4', user('K4', 'kasir', ['s4']));

    for (const id of ['s1', 's2', 's3', 's4']) {
      await put(`stores/${id}`, {
        code: id.toUpperCase(),
        name: `Toko ${id}`,
        isActive: id !== 's4',
        taxPercent: 0,
        scanEnabled: true,
        receiptHeader: 'Header',
      });
    }

    await put('stores/s1/products/p1', {
      name: 'Kopi Sachet',
      price: 1500,
      costPrice: 1100,
      stock: 10,
      isActive: true,
    });
    await put('stores/s4/products/p1', {
      name: 'Teh Sachet',
      price: 1000,
      costPrice: 700,
      stock: 5,
      isActive: true,
    });

    const trx = (cashierId, status = 'paid') => ({
      receiptNo: 'R-1',
      cashierId,
      items: [],
      total: 1000,
      paymentMethod: 'cash',
      status,
    });
    await put('stores/s1/transactions/t1', trx('k1'));
    await put('stores/s1/transactions/t2', trx('k2'));
    await put('stores/s1/transactions/tv', trx('k1', 'void'));

    await put('stores/s1/daily_summaries/2026-11-24', {
      grossSales: 1000,
      totalCost: 700,
      totalExpense: 0,
      txCount: 1,
      byPayment: { cash: 1000 },
    });
    await put('stores/s1/expenses/e1', { amount: 5000, createdBy: 'ad1' });
  });
}
