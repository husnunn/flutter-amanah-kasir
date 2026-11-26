// Membuat toko dan pengguna (admin/kasir) lewat Admin SDK, sebelum layar kelola
// pengguna di aplikasi tersedia. Berlaku untuk project ASLI maupun emulator.
//
//   node functions/scripts/provision.mjs store --project ID --id tk01 --code TK01 \
//        --name "Toko Berkah Jaya" --address "Jl. Contoh 1, Surabaya"
//
//   node functions/scripts/provision.mjs user --project ID --email kasir@contoh.com \
//        --name "Rina" --role kasir --stores tk01
//   node functions/scripts/provision.mjs user --project ID --email admin@contoh.com \
//        --name "Sari" --role admin --stores tk01,tk02
//
// Project asli: set GOOGLE_APPLICATION_CREDENTIALS (kunci service account, jangan
// di-commit). Emulator: set FIREBASE_AUTH_EMULATOR_HOST dan FIRESTORE_EMULATOR_HOST.
// Opsi lain: --password (atau env USER_PASSWORD; bila kosong ditanya), --yes.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { createRequire } from 'node:module';
import { createInterface } from 'node:readline/promises';
import { parseArgs } from 'node:util';

const require = createRequire(import.meta.url);
const { syncUserAccess } = require('../src/access.js');
const { validateUserInput } = require('../src/claims.js');

const { positionals, values } = parseArgs({
  allowPositionals: true,
  options: {
    project: { type: 'string' },
    yes: { type: 'boolean', default: false },
    // toko
    id: { type: 'string' },
    code: { type: 'string' },
    name: { type: 'string' },
    address: { type: 'string', default: '' },
    phone: { type: 'string', default: '' },
    // pengguna
    email: { type: 'string' },
    role: { type: 'string' },
    stores: { type: 'string', default: '' },
    password: { type: 'string' },
  },
});

const command = positionals[0];
const onEmulator = Boolean(process.env.FIREBASE_AUTH_EMULATOR_HOST && process.env.FIRESTORE_EMULATOR_HOST);
const projectId = values.project || process.env.GCLOUD_PROJECT || (onEmulator ? 'demo-amanah-kasir' : '');

function fail(message) {
  console.error(message);
  process.exit(1);
}

if (!['store', 'user'].includes(command)) fail('Perintah: "store" atau "user". Lihat komentar di atas berkas ini.');
if (!projectId) fail('Isi --project dengan ID project Firebase Anda.');
if (!onEmulator && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  fail('Set GOOGLE_APPLICATION_CREDENTIALS ke berkas kunci service account project ini.');
}

const rl = createInterface({ input: process.stdin, output: process.stdout });
console.log(`Target: ${onEmulator ? 'EMULATOR' : `PROJECT ASLI "${projectId}"`}`);
if (!onEmulator && !values.yes) {
  if ((await rl.question('Lanjutkan? (ketik "ya"): ')).trim().toLowerCase() !== 'ya') fail('Dibatalkan.');
}

const app = initializeApp({ projectId });
const auth = getAuth(app);
const db = getFirestore(app);

if (command === 'store') {
  rl.close();
  for (const key of ['id', 'code', 'name']) if (!values[key]) fail(`Isi --${key}.`);
  const code = values.code.trim().toUpperCase();
  try {
    await db.runTransaction(async (tx) => {
      const codeRef = db.doc(`store_codes/${code}`);
      const storeRef = db.doc(`stores/${values.id}`);
      if ((await tx.get(codeRef)).exists) throw new Error(`Kode toko "${code}" sudah dipakai.`);
      if ((await tx.get(storeRef)).exists) throw new Error(`Toko "${values.id}" sudah ada.`);
      tx.create(codeRef, { storeId: values.id, createdAt: FieldValue.serverTimestamp() });
      tx.create(storeRef, {
        code,
        name: values.name,
        address: values.address,
        phone: values.phone,
        receiptHeader: values.name,
        receiptFooter: 'Terima kasih atas kunjungan Anda',
        taxPercent: 0,
        scanEnabled: false,
        isActive: true,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  } catch (error) {
    fail(error.message);
  }
  console.log(`Toko "${values.id}" (${values.name}) dibuat.`);
} else {
  const password =
    values.password || process.env.USER_PASSWORD ||
    (await rl.question('Password pengguna (min. 8 karakter, terlihat saat diketik): ')).trim();
  rl.close();

  const parsed = validateUserInput({
    email: values.email,
    name: values.name,
    role: values.role,
    storeIds: values.stores ? values.stores.split(',').map((s) => s.trim()).filter(Boolean) : [],
    password,
  });
  if (!parsed.ok) fail(parsed.error);
  const input = parsed.value;
  if (!input.password) fail('Password wajib untuk pengguna baru.');

  const stores = await db.getAll(...input.storeIds.map((id) => db.doc(`stores/${id}`)));
  const missing = stores.filter((s) => !s.exists).map((s) => s.id);
  if (missing.length > 0) fail(`Toko belum ada: ${missing.join(', ')}. Buat dulu dengan perintah "store".`);

  let record;
  try {
    record = await auth.createUser({ email: input.email, password: input.password, displayName: input.name });
  } catch (error) {
    fail(error.code === 'auth/email-already-exists' ? 'Email sudah terdaftar.' : error.message);
  }
  await db.doc(`users/${record.uid}`).set({
    name: input.name,
    email: input.email,
    role: input.role,
    storeIds: input.storeIds,
    isActive: true,
    createdAt: FieldValue.serverTimestamp(),
  });
  const claims = await syncUserAccess({ auth, db }, record.uid);
  console.log(`Pengguna dibuat. uid=${record.uid}, claims=${JSON.stringify(claims)}`);
}
