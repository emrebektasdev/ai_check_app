const { createHash } = require('node:crypto');
async function reserveQuota(db, uid, { userLimit = 5, globalLimit = 100, now = new Date(), fail }) {
    if (![userLimit, globalLimit].every(n => Number.isInteger(n) && n > 0 && n <= 10000)) {
        throw fail('failed-precondition', 'Analiz sınırı yapılandırılmadı.');
    }
    const day = now.toISOString().slice(0, 10);
    const user = db.doc('privateScanQuotas/' + day + '_' + createHash('sha256').update(uid).digest('hex'));
    const global = db.doc('privateScanQuotas/' + day + '_global');
    await db.runTransaction(async tx => {
        const [u, g] = await Promise.all([tx.get(user), tx.get(global)]);
        const userCount = u.exists ? u.data().count : 0;
        const globalCount = g.exists ? g.data().count : 0;
        if (!Number.isSafeInteger(userCount) || !Number.isSafeInteger(globalCount) ||
            userCount >= userLimit || globalCount >= globalLimit) {
            throw fail('resource-exhausted', 'Günlük analiz sınırına ulaşıldı.');
        }
        tx.set(user, { count: userCount + 1, updatedAt: now });
        tx.set(global, { count: globalCount + 1, updatedAt: now });
    });
}
module.exports = { reserveQuota };
