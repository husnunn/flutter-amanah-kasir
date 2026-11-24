import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  collectionGroup,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  increment,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import { after, before, beforeEach, describe, it } from 'node:test';
import { anonFs, createEnv, fs, seed } from './helpers.mjs';

let env;
before(async () => {
  env = await createEnv({ firestore: true });
});
after(async () => {
  await env.cleanup();
});
beforeEach(async () => {
  await seed(env);
});

const ok = assertSucceeds;
const no = assertFails;
const d = (who, path) => doc(fs(env, who), path);

const newTrx = (cashierId, overrides = {}) => ({
  receiptNo: 'R-9',
  cashierId,
  items: [{ productId: 'p1', qty: 1 }],
  total: 1500,
  paymentMethod: 'cash',
  status: 'paid',
  ...overrides,
});

describe('users', () => {
  it('membaca dokumen sendiri', () => ok(getDoc(d('kasir', 'users/k1'))));
  it('tidak boleh membaca user lain', () => no(getDoc(d('kasir', 'users/su'))));
  it('superadmin membaca semua user', () => ok(getDoc(d('superadmin', 'users/k1'))));
  it('anonim ditolak', () => no(getDoc(doc(anonFs(env), 'users/k1'))));
  it('klien tidak boleh mengubah role sendiri', () =>
    no(updateDoc(d('kasir', 'users/k1'), { role: 'superadmin' })));
  it('superadmin pun tidak menulis users dari klien', () =>
    no(setDoc(d('superadmin', 'users/baru'), { role: 'kasir' })));
});

describe('stores', () => {
  it('kasir membaca tokonya', () => ok(getDoc(d('kasir', 'stores/s1'))));
  it('kasir tidak membaca toko lain', () => no(getDoc(d('kasir', 'stores/s2'))));
  it('admin membaca toko yang dikelola', () => ok(getDoc(d('admin', 'stores/s2'))));
  it('admin tidak membaca toko yang tidak dikelola', () =>
    no(getDoc(d('adminOther', 'stores/s1'))));
  it('superadmin membaca semua toko', () => ok(getDoc(d('superadmin', 'stores/s3'))));
  it('user tanpa peran ditolak', () => no(getDoc(d('noRole', 'stores/s1'))));

  it('admin mengubah pengaturan toko', () =>
    ok(updateDoc(d('admin', 'stores/s1'), { receiptHeader: 'Baru', taxPercent: 11 })));
  it('admin tidak mengubah nama toko', () =>
    no(updateDoc(d('admin', 'stores/s1'), { name: 'Curang' })));
  it('admin tidak menonaktifkan toko dari klien', () =>
    no(updateDoc(d('admin', 'stores/s1'), { isActive: false })));
  it('kasir tidak mengubah pengaturan toko', () =>
    no(updateDoc(d('kasir', 'stores/s1'), { receiptHeader: 'X' })));
  it('superadmin mengubah nama toko', () =>
    ok(updateDoc(d('superadmin', 'stores/s1'), { name: 'Nama Baru' })));
  it('superadmin tidak mengubah isActive dari klien (harus lewat Function)', () =>
    no(updateDoc(d('superadmin', 'stores/s1'), { isActive: false })));
  it('superadmin membuat toko baru', () =>
    ok(setDoc(d('superadmin', 'stores/s9'), { name: 'Baru', code: 'TK09', isActive: true })));
  it('admin tidak membuat toko', () =>
    no(setDoc(d('admin', 'stores/s9'), { name: 'Baru', isActive: true })));
  it('toko tidak bisa dihapus', () => no(deleteDoc(d('superadmin', 'stores/s1'))));
});

describe('products', () => {
  it('kasir membaca produk tokonya', () => ok(getDoc(d('kasir', 'stores/s1/products/p1'))));
  it('admin toko lain tidak membaca', () =>
    no(getDoc(d('adminOther', 'stores/s1/products/p1'))));
  it('user tanpa peran ditolak', () => no(getDoc(d('noRole', 'stores/s1/products/p1'))));
  it('admin membuat produk di tokonya', () =>
    ok(setDoc(d('admin', 'stores/s1/products/p2'), { name: 'Baru', price: 1000, stock: 5 })));
  it('admin tidak membuat produk di toko yang tidak dikelola', () =>
    no(setDoc(d('admin', 'stores/s3/products/p2'), { name: 'Baru' })));
  it('kasir tidak membuat produk', () =>
    no(setDoc(d('kasir', 'stores/s1/products/p2'), { name: 'Baru' })));
  it('superadmin tidak membuat produk', () =>
    no(setDoc(d('superadmin', 'stores/s1/products/p2'), { name: 'Baru' })));
  it('admin mengubah harga', () =>
    ok(updateDoc(d('admin', 'stores/s1/products/p1'), { price: 2000 })));

  it('kasir mengurangi stok (penjualan)', () =>
    ok(updateDoc(d('kasir', 'stores/s1/products/p1'), { stock: increment(-2) })));
  it('kasir tidak menaikkan stok', () =>
    no(updateDoc(d('kasir', 'stores/s1/products/p1'), { stock: increment(3) })));
  it('kasir tidak mengubah harga', () =>
    no(updateDoc(d('kasir', 'stores/s1/products/p1'), { price: 1 })));
  it('kasir tidak menyelipkan perubahan harga bersama stok', () =>
    no(updateDoc(d('kasir', 'stores/s1/products/p1'), { stock: increment(-1), price: 1 })));
  it('produk tidak bisa dihapus (nonaktifkan saja)', () =>
    no(deleteDoc(d('admin', 'stores/s1/products/p1'))));
});

describe('transactions', () => {
  it('kasir membuat transaksi atas namanya', () =>
    ok(setDoc(d('kasir', 'stores/s1/transactions/t9'), newTrx('k1'))));
  it('kasir tidak membuat transaksi atas nama kasir lain', () =>
    no(setDoc(d('kasir', 'stores/s1/transactions/t9'), newTrx('k2'))));
  it('transaksi baru wajib berstatus paid', () =>
    no(setDoc(d('kasir', 'stores/s1/transactions/t9'), newTrx('k1', { status: 'void' }))));
  it('transaksi tanpa field wajib ditolak', () =>
    no(setDoc(d('kasir', 'stores/s1/transactions/t9'), { cashierId: 'k1', status: 'paid' })));
  it('admin boleh mencatat transaksi', () =>
    ok(setDoc(d('admin', 'stores/s1/transactions/t9'), newTrx('ad1'))));
  it('superadmin tidak membuat transaksi', () =>
    no(setDoc(d('superadmin', 'stores/s1/transactions/t9'), newTrx('su'))));
  it('admin toko lain tidak membuat transaksi', () =>
    no(setDoc(d('adminOther', 'stores/s1/transactions/t9'), newTrx('ad3'))));

  it('admin membaca semua transaksi toko', () =>
    ok(getDoc(d('admin', 'stores/s1/transactions/t2'))));
  it('kasir membaca transaksinya sendiri', () =>
    ok(getDoc(d('kasir', 'stores/s1/transactions/t1'))));
  it('kasir tidak membaca transaksi kasir lain', () =>
    no(getDoc(d('kasir', 'stores/s1/transactions/t2'))));
  it('kasir list transaksi miliknya (filter cashierId)', () =>
    ok(getDocs(query(
      collection(fs(env, 'kasir'), 'stores/s1/transactions'),
      where('cashierId', '==', 'k1'),
    ))));
  it('kasir tidak bisa list semua transaksi toko', () =>
    no(getDocs(collection(fs(env, 'kasir'), 'stores/s1/transactions'))));
  it('superadmin membaca transaksi (baca saja)', () =>
    ok(getDoc(d('superadmin', 'stores/s1/transactions/t1'))));
  it('admin toko lain tidak membaca', () =>
    no(getDoc(d('adminOther', 'stores/s1/transactions/t1'))));

  it('kasir tidak bisa mem-void langsung', () =>
    no(updateDoc(d('kasir', 'stores/s1/transactions/t1'), { status: 'void', voidBy: 'k1' })));
  it('kasir mengajukan void dengan alasan', () =>
    ok(updateDoc(d('kasir', 'stores/s1/transactions/t1'), {
      voidRequest: { reason: 'Salah input', requestedBy: 'k1' },
    })));
  it('pengajuan void hanya sekali', async () => {
    const ref = d('kasir', 'stores/s1/transactions/t1');
    await ok(updateDoc(ref, { voidRequest: { reason: 'a', requestedBy: 'k1' } }));
    await no(updateDoc(ref, { voidRequest: { reason: 'b', requestedBy: 'k1' } }));
  });
  it('kasir tidak mengajukan void atas transaksi kasir lain', () =>
    no(updateDoc(d('kasir', 'stores/s1/transactions/t2'), {
      voidRequest: { reason: 'x', requestedBy: 'k1' },
    })));
  it('pengajuan void tidak boleh memalsukan pemohon', () =>
    no(updateDoc(d('kasir', 'stores/s1/transactions/t1'), {
      voidRequest: { reason: 'x', requestedBy: 'k2' },
    })));

  it('admin menyetujui void', () =>
    ok(updateDoc(d('admin', 'stores/s1/transactions/t1'), {
      status: 'void', voidBy: 'ad1', voidReason: 'Salah input',
    })));
  it('admin tidak memalsukan voidBy', () =>
    no(updateDoc(d('admin', 'stores/s1/transactions/t1'), { status: 'void', voidBy: 'k1' })));
  it('admin tidak mengubah total transaksi', () =>
    no(updateDoc(d('admin', 'stores/s1/transactions/t1'), { total: 1 })));
  it('transaksi yang sudah void tidak bisa diubah lagi', () =>
    no(updateDoc(d('admin', 'stores/s1/transactions/tv'), { status: 'paid' })));
  it('transaksi tidak bisa dihapus', () =>
    no(deleteDoc(d('admin', 'stores/s1/transactions/t1'))));
});

describe('daily_summaries', () => {
  const day = 'stores/s1/daily_summaries/2026-11-24';

  it('kasir menambah ringkasan lewat increment', () =>
    ok(setDoc(d('kasir', day), {
      grossSales: increment(500),
      totalCost: increment(300),
      txCount: increment(1),
      byPayment: { cash: increment(500) },
    }, { merge: true })));
  it('kasir membuat ringkasan hari baru', () =>
    ok(setDoc(d('kasir', 'stores/s1/daily_summaries/2026-11-25'), {
      date: '2026-11-25',
      grossSales: increment(500),
      txCount: increment(1),
    }, { merge: true })));
  it('kasir tidak menyentuh totalExpense', () =>
    no(updateDoc(d('kasir', day), { totalExpense: increment(100) })));
  it('kasir tidak menulis field tak dikenal', () =>
    no(updateDoc(d('kasir', day), { hack: 1 })));
  it('kasir tidak boleh membaca ringkasan', () => no(getDoc(d('kasir', day))));
  it('admin membaca ringkasan', () => ok(getDoc(d('admin', day))));
  it('superadmin membaca ringkasan', () => ok(getDoc(d('superadmin', day))));
  it('superadmin tidak menulis ringkasan', () =>
    no(updateDoc(d('superadmin', day), { grossSales: 1 })));
  it('admin mengubah totalExpense', () =>
    ok(updateDoc(d('admin', day), { totalExpense: increment(100) })));
  it('superadmin membaca ringkasan lintas toko (collection group)', () =>
    ok(getDocs(collectionGroup(fs(env, 'superadmin'), 'daily_summaries'))));
  it('admin tidak bisa collection group', () =>
    no(getDocs(collectionGroup(fs(env, 'admin'), 'daily_summaries'))));
  it('ringkasan tidak bisa dihapus', () => no(deleteDoc(d('admin', day))));
});

describe('expenses', () => {
  const exp = (by) => ({ amount: 100, category: 'Lainnya', createdBy: by });
  it('admin mencatat pengeluaran', () =>
    ok(setDoc(d('admin', 'stores/s1/expenses/e9'), exp('ad1'))));
  it('createdBy harus diri sendiri', () =>
    no(setDoc(d('admin', 'stores/s1/expenses/e9'), exp('su'))));
  it('kasir tidak mencatat pengeluaran', () =>
    no(setDoc(d('kasir', 'stores/s1/expenses/e9'), exp('k1'))));
  it('kasir tidak membaca pengeluaran', () => no(getDoc(d('kasir', 'stores/s1/expenses/e1'))));
  it('superadmin membaca pengeluaran', () => ok(getDoc(d('superadmin', 'stores/s1/expenses/e1'))));
  it('superadmin tidak menulis pengeluaran', () =>
    no(setDoc(d('superadmin', 'stores/s1/expenses/e9'), exp('su'))));
  it('admin toko lain tidak mengubah', () =>
    no(updateDoc(d('adminOther', 'stores/s1/expenses/e1'), { amount: 1 })));
  it('admin menghapus pengeluaran tokonya', () =>
    ok(deleteDoc(d('admin', 'stores/s1/expenses/e1'))));
});

describe('stock_movements, shifts, log', () => {
  it('kasir mencatat mutasi stok atas namanya', () =>
    ok(setDoc(d('kasir', 'stores/s1/stock_movements/m1'), { type: 'sale', createdBy: 'k1' })));
  it('mutasi stok tidak boleh atas nama orang lain', () =>
    no(setDoc(d('kasir', 'stores/s1/stock_movements/m1'), { type: 'sale', createdBy: 'k2' })));
  it('mutasi stok tidak bisa diubah', async () => {
    await ok(setDoc(d('kasir', 'stores/s1/stock_movements/m1'), { type: 'sale', createdBy: 'k1' }));
    await no(updateDoc(d('kasir', 'stores/s1/stock_movements/m1'), { type: 'in' }));
  });
  it('kasir tidak membaca mutasi stok', () =>
    no(getDoc(d('kasir', 'stores/s1/stock_movements/m1'))));
  it('admin membaca mutasi stok', () =>
    ok(getDoc(d('admin', 'stores/s1/stock_movements/m1'))));

  it('kasir membuka shift sendiri', () =>
    ok(setDoc(d('kasir', 'stores/s1/shifts/sh1'), { cashierId: 'k1', openingCash: 100000 })));
  it('kasir tidak membuka shift atas nama lain', () =>
    no(setDoc(d('kasir', 'stores/s1/shifts/sh1'), { cashierId: 'k2' })));

  it('admin membaca activity_logs', () => ok(getDoc(d('admin', 'stores/s1/activity_logs/l1'))));
  it('activity_logs tidak bisa ditulis klien', () =>
    no(setDoc(d('admin', 'stores/s1/activity_logs/l1'), { action: 'x' })));
  it('weekly_reports tidak bisa ditulis klien', () =>
    no(setDoc(d('superadmin', 'stores/s1/weekly_reports/2026-W47'), { total: 1 })));
});

describe('kategori & jalur tak dikenal', () => {
  it('admin menulis kategori', () =>
    ok(setDoc(d('admin', 'stores/s1/categories/c1'), { name: 'Minuman', sortOrder: 1 })));
  it('kasir hanya membaca kategori', async () => {
    await ok(getDoc(d('kasir', 'stores/s1/categories/c1')));
    await no(setDoc(d('kasir', 'stores/s1/categories/c1'), { name: 'X' }));
  });
  it('koleksi tak dikenal ditolak', () =>
    no(setDoc(d('admin', 'rahasia/x'), { a: 1 })));
  it('user dengan claims kosong ditolak di mana-mana', async () => {
    await no(getDoc(d('noRole', 'stores/s1/products/p1')));
    await no(setDoc(d('noRole', 'stores/s1/transactions/t9'), newTrx('x1')));
    await no(addDoc(collection(fs(env, 'noRole'), 'stores/s1/expenses'), { createdBy: 'x1' }));
  });
});
