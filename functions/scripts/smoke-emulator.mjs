// Smoke test end-to-end di Firebase Emulator (Auth + Firestore + Functions):
// seed -> login tiap persona -> cek custom claims -> panggil Cloud Functions.
//
//   cd firebase-tests && npm run smoke
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import assert from 'node:assert/strict';
import { DEMO_PASSWORD, PROJECT_ID, noRoleUser, seedAll, users } from './seed-emulator.mjs';

const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST;
const FUNCTIONS_HOST = process.env.FUNCTIONS_EMULATOR_HOST || '127.0.0.1:5001';
assert.ok(AUTH_HOST, 'FIREBASE_AUTH_EMULATOR_HOST belum diset (jalankan lewat emulators:exec).');

const byKey = Object.fromEntries(users.map((u) => [u.key, u]));
const decode = (jwt) => JSON.parse(Buffer.from(jwt.split('.')[1], 'base64url').toString());

async function signIn(email, password = DEMO_PASSWORD) {
  const res = await fetch(
    `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key`,
    {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email, password, returnSecureToken: true }),
    },
  );
  const json = await res.json();
  if (!res.ok) return { error: json.error?.message };
  return { idToken: json.idToken, refreshToken: json.refreshToken, claims: decode(json.idToken) };
}

/** Memanggil callable function. Mengembalikan {result} atau {error: {status, message}}. */
async function call(name, data, idToken) {
  const res = await fetch(
    `http://${FUNCTIONS_HOST}/${PROJECT_ID}/asia-southeast2/${name}`,
    {
      method: 'POST',
      headers: { 'content-type': 'application/json', ...(idToken ? { authorization: `Bearer ${idToken}` } : {}) },
      body: JSON.stringify({ data }),
    },
  );
  return res.json();
}

let passed = 0;
async function check(name, fn) {
  try {
    await fn();
    passed += 1;
    console.log(`  ok   ${name}`);
  } catch (error) {
    console.error(`  GAGAL ${name}\n        ${error.message}`);
    process.exitCode = 1;
  }
}

const app = initializeApp({ projectId: PROJECT_ID });
const deps = { auth: getAuth(app), db: getFirestore(app) };
await seedAll(deps);
console.log('Seed selesai. Menjalankan pemeriksaan...');

await check('superadmin: claims role=superadmin, tanpa toko', async () => {
  const s = await signIn(byKey.superadmin.email);
  assert.equal(s.claims.role, 'superadmin');
  assert.deepEqual(s.claims.storeIds, []);
});
await check('admin 3 toko: toko nonaktif (tk03) tidak masuk claims', async () => {
  const s = await signIn(byKey.admin.email);
  assert.equal(s.claims.role, 'admin');
  assert.deepEqual(s.claims.storeIds, ['tk01', 'tk02']);
});
await check('admin 1 toko: claims [tk01]', async () => {
  assert.deepEqual((await signIn(byKey.admin1.email)).claims.storeIds, ['tk01']);
});
await check('kasir: claims role=kasir, storeIds=[tk01]', async () => {
  const s = await signIn(byKey.kasir.email);
  assert.equal(s.claims.role, 'kasir');
  assert.deepEqual(s.claims.storeIds, ['tk01']);
});
await check('kasir di toko nonaktif: storeIds kosong', async () => {
  const s = await signIn(byKey.kasirTokoNonaktif.email);
  assert.equal(s.claims.role, 'kasir');
  assert.deepEqual(s.claims.storeIds, []);
});
await check('kasir nonaktif: akun Auth dinonaktifkan, tidak bisa masuk', async () => {
  assert.equal((await signIn(byKey.kasirNonaktif.email)).error, 'USER_DISABLED');
});
await check('akun tanpa peran: masuk tetapi tanpa claims role', async () => {
  const s = await signIn(noRoleUser.email);
  assert.equal(s.claims.role, undefined);
});
await check('password salah ditolak', async () => {
  assert.ok((await signIn(byKey.kasir.email, 'salah-total')).error);
});

const superToken = (await signIn(byKey.superadmin.email)).idToken;
const adminToken = (await signIn(byKey.admin.email)).idToken;
const kasirSession = await signIn(byKey.kasir.email);

await check('upsertUser tanpa login ditolak', async () => {
  const r = await call('upsertUser', {});
  assert.equal(r.error?.status, 'UNAUTHENTICATED');
});
await check('upsertUser oleh kasir ditolak', async () => {
  const r = await call('upsertUser', { email: 'a@b.co', name: 'A', role: 'kasir', storeIds: ['tk01'], password: 'password123' }, kasirSession.idToken);
  assert.equal(r.error?.status, 'PERMISSION_DENIED');
});
await check('upsertUser oleh admin ditolak (ADMIN_CAN_MANAGE_KASIR = false)', async () => {
  const r = await call('upsertUser', { email: 'a@b.co', name: 'A', role: 'kasir', storeIds: ['tk01'], password: 'password123' }, adminToken);
  assert.equal(r.error?.status, 'PERMISSION_DENIED');
});
await check('upsertUser: kasir dengan 2 toko ditolak validasi', async () => {
  const r = await call('upsertUser', { email: 'a@b.co', name: 'A', role: 'kasir', storeIds: ['tk01', 'tk02'], password: 'password123' }, superToken);
  assert.equal(r.error?.status, 'INVALID_ARGUMENT');
});
await check('upsertUser: toko yang tidak ada ditolak', async () => {
  const r = await call('upsertUser', { email: 'a@b.co', name: 'A', role: 'kasir', storeIds: ['tk99'], password: 'password123' }, superToken);
  assert.equal(r.error?.status, 'NOT_FOUND');
});
await check('upsertUser: pengguna baru tanpa password ditolak', async () => {
  const r = await call('upsertUser', { email: 'baru@amanah.test', name: 'Baru', role: 'kasir', storeIds: ['tk01'] }, superToken);
  assert.equal(r.error?.status, 'INVALID_ARGUMENT');
});
await check('upsertUser oleh superadmin: kasir baru bisa login dengan claims benar', async () => {
  const r = await call('upsertUser', { email: 'baru@amanah.test', name: 'Kasir Baru', role: 'kasir', storeIds: ['tk02'], password: 'rahasia-123' }, superToken);
  assert.equal(r.result?.created, true, JSON.stringify(r));
  const s = await signIn('baru@amanah.test', 'rahasia-123');
  assert.equal(s.claims.role, 'kasir');
  assert.deepEqual(s.claims.storeIds, ['tk02']);
});
await check('upsertUser: email yang sama ditolak', async () => {
  const r = await call('upsertUser', { email: 'baru@amanah.test', name: 'Lagi', role: 'kasir', storeIds: ['tk01'], password: 'rahasia-123' }, superToken);
  assert.equal(r.error?.status, 'ALREADY_EXISTS');
});

let newStoreId;
await check('upsertStore tanpa login ditolak', async () => {
  const r = await call('upsertStore', { code: 'NEW1', name: 'Toko Baru' });
  assert.equal(r.error?.status, 'UNAUTHENTICATED');
});
await check('upsertStore oleh admin ditolak', async () => {
  const r = await call('upsertStore', { code: 'NEW1', name: 'Toko Baru' }, adminToken);
  assert.equal(r.error?.status, 'PERMISSION_DENIED');
});
await check('upsertStore: toko baru dibuat dengan id otomatis dan kode terdaftar', async () => {
  const r = await call('upsertStore', { code: ' new1 ', name: 'Toko Baru', address: 'Jl. Baru 1', phone: '0812-000', scanEnabled: true }, superToken);
  assert.equal(r.result?.created, true, JSON.stringify(r));
  newStoreId = r.result.storeId;
  const store = (await deps.db.doc(`stores/${newStoreId}`).get()).data();
  assert.equal(store.code, 'NEW1');
  assert.equal(store.isActive, true);
  assert.equal(store.scanEnabled, true);
  assert.equal(store.receiptHeader, 'Toko Baru');
  assert.equal((await deps.db.doc('store_codes/NEW1').get()).get('storeId'), newStoreId);
});
await check('upsertStore: kode ganda ditolak (tanpa peduli huruf besar/kecil)', async () => {
  for (const code of ['NEW1', 'new1', 'TK01']) {
    const r = await call('upsertStore', { code, name: 'Lagi' }, superToken);
    assert.equal(r.error?.status, 'ALREADY_EXISTS', `${code}: ${JSON.stringify(r)}`);
  }
});
await check('upsertStore: kode tidak valid dan nama kosong ditolak', async () => {
  for (const bad of [{ code: 'x', name: 'Toko' }, { code: 'ADA SPASI', name: 'Toko' }, { code: 'OKE1', name: ' ' }, { name: 'Tanpa kode' }]) {
    const r = await call('upsertStore', bad, superToken);
    assert.equal(r.error?.status, 'INVALID_ARGUMENT', JSON.stringify(bad));
  }
});
await check('upsertStore: ubah nama/alamat, kode tetap dan tidak bisa diubah', async () => {
  const ok = await call('upsertStore', { storeId: newStoreId, code: 'NEW1', name: 'Toko Baru 2', address: 'Jl. Baru 2' }, superToken);
  assert.equal(ok.result?.created, false, JSON.stringify(ok));
  assert.equal((await deps.db.doc(`stores/${newStoreId}`).get()).get('name'), 'Toko Baru 2');
  const bad = await call('upsertStore', { storeId: newStoreId, code: 'NEW2', name: 'Toko Baru 2' }, superToken);
  assert.equal(bad.error?.status, 'INVALID_ARGUMENT', JSON.stringify(bad));
  const missing = await call('upsertStore', { storeId: 'tidak-ada', name: 'Toko' }, superToken);
  assert.equal(missing.error?.status, 'NOT_FOUND', JSON.stringify(missing));
});

await check('setStoreActive(tk01, false): claims kasir dicabut + refresh token di-revoke', async () => {
  // Catatan: Auth Emulator tidak menegakkan pencabutan saat refresh token ditukar
  // (Firebase asli menolaknya dengan TOKEN_EXPIRED). Yang bisa diverifikasi di sini:
  // revokeRefreshTokens benar-benar dipanggil -> tokensValidAfterTime user maju.
  const before = Date.now() - 1000;
  const r = await call('setStoreActive', { storeId: 'tk01', isActive: false }, superToken);
  assert.ok(r.result?.affectedUsers >= 3, JSON.stringify(r));
  const record = await deps.auth.getUser(byKey.kasir.key);
  assert.ok(
    new Date(record.tokensValidAfterTime).getTime() >= before,
    `tokensValidAfterTime=${record.tokensValidAfterTime}`,
  );
  const again = await signIn(byKey.kasir.email);
  assert.deepEqual(again.claims.storeIds, []);
});
await check('setStoreActive(tk01, true): akses kembali', async () => {
  await call('setStoreActive', { storeId: 'tk01', isActive: true }, superToken);
  assert.deepEqual((await signIn(byKey.kasir.email)).claims.storeIds, ['tk01']);
});
await check('setUserActive(kasir, false): tidak bisa masuk lagi', async () => {
  const r = await call('setUserActive', { uid: 'kasir', isActive: false }, superToken);
  assert.equal(r.result?.isActive, false, JSON.stringify(r));
  assert.equal((await signIn(byKey.kasir.email)).error, 'USER_DISABLED');
});
await check('setUserActive: superadmin tidak bisa menonaktifkan dirinya', async () => {
  const r = await call('setUserActive', { uid: 'superadmin', isActive: false }, superToken);
  assert.equal(r.error?.status, 'FAILED_PRECONDITION');
});
await check('setStoreActive oleh admin ditolak', async () => {
  const r = await call('setStoreActive', { storeId: 'tk01', isActive: false }, adminToken);
  assert.equal(r.error?.status, 'PERMISSION_DENIED');
});

console.log(`\n${passed} pemeriksaan lolos${process.exitCode ? ', ADA YANG GAGAL' : ''}.`);
