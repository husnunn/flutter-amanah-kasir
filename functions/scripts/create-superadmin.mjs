// Membuat (atau memperbarui) superadmin pertama.
//
// Project ASLI (butuh kunci service account, JANGAN di-commit):
//   export GOOGLE_APPLICATION_CREDENTIALS=/jalur/aman/serviceAccount.json
//   node functions/scripts/create-superadmin.mjs \
//        --project ID-PROJECT-ANDA --email pemilik@contoh.com --name "Nama Pemilik"
//
// Emulator: set FIREBASE_AUTH_EMULATOR_HOST dan FIRESTORE_EMULATOR_HOST dulu.
//
// Opsi: --password (atau env SUPERADMIN_PASSWORD; bila kosong akan ditanya),
//       --yes (lewati konfirmasi untuk project asli).
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { createRequire } from 'node:module';
import { createInterface } from 'node:readline/promises';
import { parseArgs } from 'node:util';

const require = createRequire(import.meta.url);
const { syncUserAccess } = require('../src/access.js');

const { values } = parseArgs({
  options: {
    project: { type: 'string' },
    email: { type: 'string' },
    name: { type: 'string' },
    password: { type: 'string' },
    yes: { type: 'boolean', default: false },
  },
});

const onEmulator = Boolean(process.env.FIREBASE_AUTH_EMULATOR_HOST && process.env.FIRESTORE_EMULATOR_HOST);
const projectId = values.project || process.env.GCLOUD_PROJECT || (onEmulator ? 'demo-amanah-kasir' : '');

function fail(message) {
  console.error(message);
  process.exit(1);
}

if (!projectId) fail('Isi --project dengan ID project Firebase Anda.');
if (!values.email) fail('Isi --email.');
if (!values.name) fail('Isi --name.');
if (!onEmulator && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  fail('Set GOOGLE_APPLICATION_CREDENTIALS ke berkas kunci service account project ini.');
}

const rl = createInterface({ input: process.stdin, output: process.stdout });

async function askPassword() {
  const fromEnv = values.password || process.env.SUPERADMIN_PASSWORD;
  if (fromEnv) return fromEnv;
  return (await rl.question('Password superadmin (min. 8 karakter, terlihat saat diketik): ')).trim();
}

console.log(`Target : ${onEmulator ? 'EMULATOR' : `PROJECT ASLI "${projectId}"`}`);
console.log(`Akun   : ${values.email} (${values.name}) sebagai superadmin`);
if (!onEmulator && !values.yes) {
  const answer = await rl.question('Lanjutkan? (ketik "ya"): ');
  if (answer.trim().toLowerCase() !== 'ya') fail('Dibatalkan.');
}

const password = await askPassword();
rl.close();
if (password.length < 8) fail('Password minimal 8 karakter.');

const app = initializeApp({ projectId });
const auth = getAuth(app);
const db = getFirestore(app);
const email = values.email.trim().toLowerCase();

let uid;
try {
  const existing = await auth.getUserByEmail(email);
  uid = existing.uid;
  await auth.updateUser(uid, { password, displayName: values.name, disabled: false });
  console.log('Akun Auth sudah ada: password dan nama diperbarui.');
} catch (error) {
  if (error.code !== 'auth/user-not-found') throw error;
  uid = (await auth.createUser({ email, password, displayName: values.name })).uid;
  console.log('Akun Auth dibuat.');
}

await db.doc(`users/${uid}`).set(
  {
    name: values.name,
    email,
    role: 'superadmin',
    storeIds: [],
    isActive: true,
    createdAt: FieldValue.serverTimestamp(),
  },
  { merge: true },
);
const claims = await syncUserAccess({ auth, db }, uid, { revoke: true });
console.log(`Selesai. uid=${uid}, claims=${JSON.stringify(claims)}`);
console.log('Masuk ke aplikasi dengan email dan password tadi.');
