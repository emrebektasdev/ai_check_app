const { test, before, after, beforeEach } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, setDoc, getDoc, updateDoc, deleteDoc } = require('firebase/firestore');
const { ref, uploadBytes, getBytes } = require('firebase/storage');
let env;
const scan = { id: 's1', imagePath: '', aiScore: 0.8, isAiGenerated: true, confidence: 0.8, detectedModel: '', timestamp: '2026-10-14' };
const db = uid => uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();
before(async () => { env = await initializeTestEnvironment({ projectId: 'demo-aicheck-security',
 firestore: { rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8') },
 storage: { rules: fs.readFileSync(path.join(__dirname, '..', 'storage.rules'), 'utf8') } }); });
beforeEach(async () => {
 await env.clearFirestore(); await env.clearStorage();
 await env.withSecurityRulesDisabled(c => setDoc(doc(c.firestore(), 'users/alice/scan_history/s1'), scan));
});
after(async () => { await env.cleanup(); });
test('history stays private and rejects injected rights or invalid scores', async () => {
 const target = uid => doc(db(uid), 'users/alice/scan_history/s1');
 await assertFails(getDoc(target()));
 await assertFails(getDoc(target('bob')));
 await assertFails(updateDoc(target('bob'), { aiScore: 0 }));
 await assertSucceeds(getDoc(target('alice')));
 await assertSucceeds(updateDoc(target('alice'), { aiScore: 0.5 }));
 for (const fields of [{ isPremium: true }, { aiScore: -1 }, { aiScore: 2 }, { id: 'other' }]) {
  await assertFails(updateDoc(target('alice'), fields));
 }
 await assertFails(deleteDoc(target('bob')));
 await assertSucceeds(deleteDoc(target('alice')));
 await assertSucceeds(setDoc(target('alice'), scan));
});
test('client cannot read or reset server quota, grant premium or use direct image storage', async () => {
 for (const uid of [undefined, 'alice']) {
  for (const name of ['privateScanQuotas/alice', 'users/alice', 'globalScanQuotas/today']) {
   await assertFails(getDoc(doc(db(uid), name)));
   await assertFails(setDoc(doc(db(uid), name), { count: 0, isPremium: true }));
  }
 }
 const storage=env.authenticatedContext('alice').storage();
 await assertFails(uploadBytes(ref(storage, 'images/alice/a.jpg'), new Uint8Array([1]), { contentType: 'image/jpeg' }));
 await assertFails(getBytes(ref(storage, 'images/alice/a.jpg')));
});
