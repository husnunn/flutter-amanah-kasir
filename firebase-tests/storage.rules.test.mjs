import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, ref, uploadBytes } from 'firebase/storage';
import { after, before, beforeEach, describe, it } from 'node:test';
import { createEnv, storage } from './helpers.mjs';

let env;
before(async () => {
  env = await createEnv();
});
after(async () => {
  await env.cleanup();
});
beforeEach(async () => {
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async (admin) => {
    await uploadBytes(
      ref(admin.storage(), 'stores/s1/products/a.jpg'),
      new Uint8Array([1, 2, 3]),
      { contentType: 'image/jpeg' },
    );
  });
});

const ok = assertSucceeds;
const no = assertFails;
const file = (who, path) => ref(storage(env, who), path);
const image = { contentType: 'image/jpeg' };
const small = new Uint8Array([1, 2, 3, 4]);

describe('storage: foto produk & bukti pengeluaran', () => {
  it('admin mengunggah gambar ke tokonya', () =>
    ok(uploadBytes(file('admin', 'stores/s1/products/b.jpg'), small, image)));
  it('admin tidak mengunggah file non-gambar', () =>
    no(uploadBytes(file('admin', 'stores/s1/products/b.pdf'), small, {
      contentType: 'application/pdf',
    })));
  it('admin tidak mengunggah file lebih dari 5 MB', () =>
    no(uploadBytes(
      file('admin', 'stores/s1/products/besar.jpg'),
      new Uint8Array(6 * 1024 * 1024),
      image,
    )));
  it('admin tidak mengunggah ke toko yang tidak dikelola', () =>
    no(uploadBytes(file('admin', 'stores/s3/products/b.jpg'), small, image)));
  it('kasir tidak boleh mengunggah', () =>
    no(uploadBytes(file('kasir', 'stores/s1/products/b.jpg'), small, image)));
  it('superadmin tidak mengunggah (baca saja)', () =>
    no(uploadBytes(file('superadmin', 'stores/s1/products/b.jpg'), small, image)));

  it('kasir membaca foto tokonya', () =>
    ok(getBytes(file('kasir', 'stores/s1/products/a.jpg'))));
  it('kasir tidak membaca foto toko lain', () =>
    no(getBytes(file('adminOther', 'stores/s1/products/a.jpg'))));
  it('superadmin membaca foto', () =>
    ok(getBytes(file('superadmin', 'stores/s1/products/a.jpg'))));
  it('user tanpa peran ditolak', () =>
    no(getBytes(file('noRole', 'stores/s1/products/a.jpg'))));

  it('admin menghapus foto tokonya', () =>
    ok(deleteObject(file('admin', 'stores/s1/products/a.jpg'))));
  it('kasir tidak menghapus foto', () =>
    no(deleteObject(file('kasir', 'stores/s1/products/a.jpg'))));
  it('path di luar stores/ ditolak', () =>
    no(uploadBytes(file('admin', 'umum/x.jpg'), small, image)));
});
