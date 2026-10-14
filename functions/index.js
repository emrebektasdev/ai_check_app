const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret, defineInt } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { createHandler } = require('./analyze');
const { reserveQuota } = require('./quota');
initializeApp();
const apiUser = defineSecret('SIGHTENGINE_API_USER');
const apiSecret = defineSecret('SIGHTENGINE_API_SECRET');
const dailyGlobalLimit = defineInt('DAILY_GLOBAL_SCAN_LIMIT', { default: 100 });
const fail = (code, message) => new HttpsError(code, message);
exports.analyzeImage = onCall({
    region: 'europe-west1', enforceAppCheck: true, maxInstances: 2,
    concurrency: 10, timeoutSeconds: 40, memory: '256MiB', secrets: [apiUser, apiSecret],
}, createHandler({
    fail,
    reserve: uid => reserveQuota(getFirestore(), uid, { globalLimit: dailyGlobalLimit.value(), fail }),
    analyze: async ({ bytes, mime }) => {
        const form = new FormData();
        form.set('models', 'genai');
        form.set('api_user', apiUser.value());
        form.set('api_secret', apiSecret.value());
        form.set('media', new Blob([bytes], { type: mime }), 'image');
        const response = await fetch('https://api.sightengine.com/1.0/check.json', {
            method: 'POST', body: form, signal: AbortSignal.timeout(25000),
        });
        if (!response.ok) throw new Error('Upstream unavailable');
        const result = await response.json();
        if (result.status !== 'success') throw new Error('Upstream rejected');
        return result.type?.ai_generated;
    },
}));
