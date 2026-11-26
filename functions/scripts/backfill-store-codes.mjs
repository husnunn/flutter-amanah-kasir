// Mendaftarkan kode toko yang sudah ada ke `store_codes/{KODE}`.
//
// Toko yang dibuat SEBELUM fungsi `upsertStore` ada (lewat provision.mjs lama,
// seed, atau console) belum terdaftar di `store_codes`, sehingga penjaga
// keunikan kode tidak mengenalnya dan kodenya bisa dipakai ulang. Jalankan skrip
// ini sekali di project yang sudah berisi toko. Aman diulang: yang sudah terdaftar
// dilewati, dan kode kembar antar toko dilaporkan tanpa mengubah apa pun.
//
//   GOOGLE_APPLICATION_CREDENTIALS=~/rahasia/kunci.json \
//     node functions/scripts/backfill-store-codes.mjs --project ID-PROJECT
//
// Emulator: set FIRESTORE_EMULATOR_HOST. Opsi: --yes (lewati konfirmasi).
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { createRequire } from 'node:module';
import { createInterface } from 'node:readline/promises';
import { parseArgs } from 'node:util';

const require = createRequire(import.meta.url);
const { normalizeCode } = require('../src/stores.js');

const { values } = parseArgs({
  options: {
    project: { type: 'string' },
    yes: { type: 'boolean', default: false },
  },
});

const onEmulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
const projectId = values.project || process.env.GCLOUD_PROJECT || (onEmulator ? 'demo-amanah-kasir' : '');

function fail(message) {
  console.error(message);
  process.exit(1);
}

if (!projectId) fail('Isi --project dengan ID project Firebase Anda.');
if (!onEmulator && !process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  fail('Set GOOGLE_APPLICATION_CREDENTIALS ke berkas kunci service account project ini.');
}

console.log(`Target: ${onEmulator ? 'EMULATOR' : `PROJECT ASLI "${projectId}"`}`);
if (!onEmulator && !values.yes) {
  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const answer = await rl.question('Lanjutkan? (ketik "ya"): ');
  rl.close();
  if (answer.trim().toLowerCase() !== 'ya') fail('Dibatalkan.');
}

const db = getFirestore(initializeApp({ projectId }));
const stores = await db.collection('stores').get();

// Satu kode hanya boleh dimiliki satu toko; kembar dilaporkan, tidak ditimpa.
const owners = new Map();
const problems = [];
for (const doc of stores.docs) {
  const code = normalizeCode(doc.get('code'));
  if (!code) {
    problems.push(`Toko "${doc.id}" tidak punya kode.`);
  } else if (owners.has(code)) {
    problems.push(`Kode ${code} dipakai dua toko: "${owners.get(code)}" dan "${doc.id}". Ubah salah satunya lebih dulu.`);
  } else {
    owners.set(code, doc.id);
  }
}

let added = 0;
let skipped = 0;
for (const [code, storeId] of owners) {
  const ref = db.doc(`store_codes/${code}`);
  const existing = await ref.get();
  if (existing.exists) {
    if (existing.get('storeId') !== storeId) {
      problems.push(`store_codes/${code} menunjuk toko lain ("${existing.get('storeId')}"), bukan "${storeId}".`);
    }
    skipped += 1;
    continue;
  }
  await ref.create({ storeId, createdAt: FieldValue.serverTimestamp() });
  added += 1;
}

console.log(`Toko diperiksa: ${stores.size}. Kode didaftarkan: ${added}. Sudah terdaftar: ${skipped}.`);
if (problems.length > 0) {
  console.error('\nPerlu ditangani manual:');
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(2);
}
