const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createHandler, MAX_BYTES } = require('../analyze');
const { reserveQuota } = require('../quota');
const fail = (code, message) => Object.assign(new Error(message), { code });
const valid = () => ({ auth: { uid: 'alice', token: { email_verified: true, firebase: { sign_in_provider: 'google.com' } } },
 app: { appId: 'trusted-test-app' }, data: { mimeType: 'image/jpeg', imageBase64: Buffer.from([255,216,255,0]).toString('base64') } });
test('rejects unsigned, anonymous, unverified and unattested requests before spending quota', async () => {
 let calls = 0;
 const handler = createHandler({ fail, reserve: async () => { calls++; }, analyze: async () => 0.6 });
 const unsigned = valid(); delete unsigned.auth;
 const anonymous = valid(); anonymous.auth.token.firebase.sign_in_provider = 'anonymous';
 const unverified = valid(); unverified.auth.token.email_verified = false;
 const unattested = valid(); delete unattested.app;
 for (const request of [unsigned, anonymous, unverified, unattested]) await assert.rejects(handler(request));
 assert.equal(calls, 0);
});
test('rejects oversized, invalid and mismatched payloads; strips extra fields', async () => {
 const handler = createHandler({ fail, reserve: async () => {}, analyze: async () => 0.6 });
 for (const data of [
  { mimeType:'image/jpeg', imageBase64:'not base64' },
  { mimeType:'image/png', imageBase64:valid().data.imageBase64 },
  { ...valid().data, api_secret:'client-key' },
  { mimeType:'image/jpeg', imageBase64:Buffer.alloc(MAX_BYTES+1).toString('base64') },
 ]) await assert.rejects(handler({...valid(),data}), e => e.code === 'invalid-argument');
 assert.deepEqual(await handler(valid()), { status:'success', type:{ai_generated:0.6} });
});
test('invalid upstream responses and errors fail closed without leaking provider secrets', async () => {
 for (const score of [undefined, NaN, 4, -1]) {
  const h=createHandler({fail,reserve:async()=>{},analyze:async()=>score});
  await assert.rejects(h(valid()), e=>e.code==='unavailable');
 }
 const h=createHandler({fail,reserve:async()=>{},analyze:async()=>{throw new Error('secret-provider-error');}});
 await assert.rejects(h(valid()),e=>!e.message.includes('secret-provider-error'));
});
test('server quota counts attempts and enforces per-user/global limits atomically', async () => {
 const records=new Map();let lock=Promise.resolve();
 const db={doc:path=>path,runTransaction:fn=>{
  const result=lock.then(()=>fn({get:async path=>({exists:records.has(path),data:()=>records.get(path)}),set:(path,data)=>records.set(path,data)}));
  lock=result.catch(()=>{});return result;
 }};
 const opts={fail,now:new Date('2026-10-14T12:00:00Z'),userLimit:5,globalLimit:6};
 const results=await Promise.allSettled(Array.from({length:7},()=>reserveQuota(db,'alice',opts)));
 assert.equal(results.filter(r=>r.status==='fulfilled').length,5);
 await reserveQuota(db,'bob',opts);
 await assert.rejects(reserveQuota(db,'charlie',opts),e=>e.code==='resource-exhausted');
 await reserveQuota(db,'alice',{...opts,now:new Date('2026-10-15T00:00:00Z')});
});
