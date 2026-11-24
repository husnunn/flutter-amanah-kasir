import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';
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

/** Persona = uid + custom claims seperti yang diset Cloud Function. */
export const personas = {
  superadmin: { uid: 'su', claims: { role: 'superadmin', storeIds: [] } },
  admin: { uid: 'ad1', claims: { role: 'admin', storeIds: ['s1', 's2'] } },
  adminOther: { uid: 'ad3', claims: { role: 'admin', storeIds: ['s3'] } },
  kasir: { uid: 'k1', claims: { role: 'kasir', storeIds: ['s1'] } },
  kasirB: { uid: 'k2', claims: { role: 'kasir', storeIds: ['s1'] } },
  noRole: { uid: 'x1', claims: {} },
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

    await put('users/su', { role: 'superadmin', storeIds: [], isActive: true });
    await put('users/ad1', { role: 'admin', storeIds: ['s1', 's2'], isActive: true });
    await put('users/k1', { role: 'kasir', storeIds: ['s1'], isActive: true });

    for (const id of ['s1', 's2', 's3']) {
      await put(`stores/${id}`, {
        code: id.toUpperCase(),
        name: `Toko ${id}`,
        isActive: true,
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
