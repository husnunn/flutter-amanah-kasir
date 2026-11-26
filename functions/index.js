'use strict';

const { initializeApp } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { FieldValue, getFirestore } = require('firebase-admin/firestore');
const { setGlobalOptions } = require('firebase-functions/v2');
const { HttpsError, onCall } = require('firebase-functions/v2/https');

const { syncUserAccess } = require('./src/access');
const { canManage, validateUserInput } = require('./src/claims');
const { validateStoreInput } = require('./src/stores');

initializeApp();

// Jakarta; klien Flutter memakai region yang sama.
setGlobalOptions({ region: 'asia-southeast2', maxInstances: 5 });

const auth = getAuth();
const db = getFirestore();
const deps = { auth, db };

/** Pemanggil harus login dan punya claims peran. */
function requireCaller(request) {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Harus login.');
  }
  const { role, storeIds } = request.auth.token;
  if (!role) {
    throw new HttpsError('permission-denied', 'Akun belum memiliki peran.');
  }
  return { uid: request.auth.uid, role, storeIds: storeIds || [] };
}

function requireSuperadmin(request) {
  const caller = requireCaller(request);
  if (caller.role !== 'superadmin') {
    throw new HttpsError('permission-denied', 'Hanya superadmin.');
  }
  return caller;
}

/**
 * Membuat atau mengubah user: akun Auth, dokumen users/{uid}, lalu custom claims.
 * data: {uid?, email, name, role, storeIds, password?, isActive?}
 * Membuat user baru wajib menyertakan password; tanpa uid = membuat baru.
 */
exports.upsertUser = onCall(async (request) => {
  const caller = requireCaller(request);

  const parsed = validateUserInput(request.data);
  if (!parsed.ok) throw new HttpsError('invalid-argument', parsed.error);
  const input = parsed.value;

  if (!canManage(caller, input)) {
    throw new HttpsError('permission-denied', 'Tidak berhak mengelola pengguna ini.');
  }

  if (input.storeIds.length > 0) {
    const stores = await db.getAll(...input.storeIds.map((id) => db.doc(`stores/${id}`)));
    const missing = stores.filter((s) => !s.exists).map((s) => s.id);
    if (missing.length > 0) {
      throw new HttpsError('not-found', `Toko tidak ditemukan: ${missing.join(', ')}`);
    }
  }

  let uid = input.uid;
  const created = !uid;
  try {
    if (created) {
      if (!input.password) {
        throw new HttpsError('invalid-argument', 'Password wajib untuk pengguna baru.');
      }
      const record = await auth.createUser({
        email: input.email,
        password: input.password,
        displayName: input.name,
      });
      uid = record.uid;
    } else {
      const update = { email: input.email, displayName: input.name };
      if (input.password) update.password = input.password;
      await auth.updateUser(uid, update);
    }
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    if (error.code === 'auth/email-already-exists') {
      throw new HttpsError('already-exists', 'Email sudah terdaftar.');
    }
    if (error.code === 'auth/user-not-found') {
      throw new HttpsError('not-found', 'Pengguna tidak ditemukan.');
    }
    throw new HttpsError('internal', error.message);
  }

  await db.doc(`users/${uid}`).set(
    {
      name: input.name,
      email: input.email,
      role: input.role,
      storeIds: input.storeIds,
      isActive: input.isActive,
      updatedAt: FieldValue.serverTimestamp(),
      ...(created ? { createdAt: FieldValue.serverTimestamp() } : {}),
    },
    { merge: true },
  );

  const claims = await syncUserAccess(deps, uid, { revoke: !created });
  return { uid, created, claims };
});

/** Mengaktifkan/menonaktifkan user. Menonaktifkan = claims dicabut + token di-revoke. */
exports.setUserActive = onCall(async (request) => {
  const caller = requireSuperadmin(request);
  const { uid, isActive } = request.data || {};
  if (typeof uid !== 'string' || !uid || typeof isActive !== 'boolean') {
    throw new HttpsError('invalid-argument', 'uid dan isActive wajib diisi.');
  }
  if (uid === caller.uid && !isActive) {
    throw new HttpsError('failed-precondition', 'Tidak bisa menonaktifkan akun sendiri.');
  }
  const ref = db.doc(`users/${uid}`);
  if (!(await ref.get()).exists) {
    throw new HttpsError('not-found', 'Pengguna tidak ditemukan.');
  }
  await ref.update({ isActive, updatedAt: FieldValue.serverTimestamp() });
  const claims = await syncUserAccess(deps, uid, { revoke: !isActive });
  return { uid, isActive, claims };
});

/**
 * Mengaktifkan/menonaktifkan toko, lalu menyelaraskan claims semua user toko itu
 * (toko nonaktif hilang dari storeIds mereka).
 */
exports.setStoreActive = onCall(async (request) => {
  requireSuperadmin(request);
  const { storeId, isActive } = request.data || {};
  if (typeof storeId !== 'string' || !storeId || typeof isActive !== 'boolean') {
    throw new HttpsError('invalid-argument', 'storeId dan isActive wajib diisi.');
  }
  const ref = db.doc(`stores/${storeId}`);
  if (!(await ref.get()).exists) {
    throw new HttpsError('not-found', 'Toko tidak ditemukan.');
  }
  await ref.update({ isActive, updatedAt: FieldValue.serverTimestamp() });

  const members = await db.collection('users').where('storeIds', 'array-contains', storeId).get();
  await Promise.all(
    members.docs.map((doc) => syncUserAccess(deps, doc.id, { revoke: !isActive })),
  );
  return { storeId, isActive, affectedUsers: members.size };
});

/**
 * Membuat atau mengubah toko (hanya superadmin).
 * data: {storeId?, code, name, address?, phone?, scanEnabled?}; tanpa storeId = buat baru.
 *
 * Kode toko dipakai di nomor nota dan harus unik. Firestore tidak bisa menjamin
 * keunikan lewat rules, jadi pembuatan toko memakai transaksi atas
 * `store_codes/{kode}`. Kode tidak bisa diubah setelah toko dibuat.
 */
exports.upsertStore = onCall(async (request) => {
  requireSuperadmin(request);
  const data = request.data || {};
  const isCreate = !data.storeId;

  const parsed = validateStoreInput(data, { isCreate });
  if (!parsed.ok) throw new HttpsError('invalid-argument', parsed.error);
  const input = parsed.value;

  if (isCreate) {
    const storeRef = db.collection('stores').doc();
    const codeRef = db.doc(`store_codes/${input.code}`);
    await db.runTransaction(async (tx) => {
      if ((await tx.get(codeRef)).exists) {
        throw new HttpsError('already-exists', `Kode toko ${input.code} sudah dipakai.`);
      }
      tx.create(codeRef, { storeId: storeRef.id, createdAt: FieldValue.serverTimestamp() });
      tx.create(storeRef, {
        code: input.code,
        name: input.name,
        address: input.address,
        phone: input.phone,
        receiptHeader: input.name,
        receiptFooter: 'Terima kasih atas kunjungan Anda',
        taxPercent: 0,
        scanEnabled: input.scanEnabled === true,
        isActive: true,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
    return { storeId: storeRef.id, created: true };
  }

  const ref = db.doc(`stores/${input.storeId}`);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Toko tidak ditemukan.');
  if (input.code && input.code !== snap.get('code')) {
    throw new HttpsError('invalid-argument', 'Kode toko tidak bisa diubah.');
  }
  await ref.update({
    name: input.name,
    address: input.address,
    phone: input.phone,
    ...(input.scanEnabled === undefined ? {} : { scanEnabled: input.scanEnabled }),
    updatedAt: FieldValue.serverTimestamp(),
  });
  return { storeId: input.storeId, created: false };
});
