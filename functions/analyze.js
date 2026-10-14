const MAX_BYTES = 5 * 1024 * 1024;
function decodeImage(data, fail) {
    if (!data || typeof data.imageBase64 !== 'string' ||
        Object.keys(data).some(k => !['imageBase64', 'mimeType'].includes(k)) ||
        data.imageBase64.length > Math.ceil(MAX_BYTES / 3) * 4 ||
        !/^[A-Za-z0-9+/]+={0,2}$/.test(data.imageBase64)) {
        throw fail('invalid-argument', 'Geçersiz görsel. En fazla 5 MB JPEG, PNG veya WebP gönderin.');
    }
    const bytes = Buffer.from(data.imageBase64, 'base64');
    if (!bytes.length || bytes.length > MAX_BYTES || bytes.toString('base64') !== data.imageBase64) {
        throw fail('invalid-argument', 'Geçersiz görsel.');
    }
    const isJpeg = bytes.length >= 3 && bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff;
    const isPng = bytes.subarray(0, 8).equals(Buffer.from([137,80,78,71,13,10,26,10]));
    const isWebp = bytes.toString('ascii',0,4) === 'RIFF' && bytes.toString('ascii',8,12) === 'WEBP';
    const mime = isJpeg ? 'image/jpeg' : isPng ? 'image/png' : isWebp ? 'image/webp' : null;
    if (!mime || data.mimeType !== mime) throw fail('invalid-argument', 'Desteklenmeyen görsel biçimi.');
    return { bytes, mime };
}
function createHandler({ reserve, analyze, fail }) {
    return async request => {
        if (!request.auth || request.auth.token?.firebase?.sign_in_provider === 'anonymous' ||
            request.auth.token?.email_verified !== true) {
            throw fail('unauthenticated', 'Analiz için doğrulanmış hesabınızla giriş yapın.');
        }
        if (!request.app) throw fail('failed-precondition', 'Uygulama doğrulanamadı.');
        const image = decodeImage(request.data, fail);
        await reserve(request.auth.uid);
        try {
            const score = await analyze(image);
            if (typeof score !== 'number' || !Number.isFinite(score) || score < 0 || score > 1) throw new Error('Invalid score');
            return { status: 'success', type: { ai_generated: score } };
        } catch {
            // Never return upstream errors, credentials, request bodies or image bytes.
            throw fail('unavailable', 'Analiz servisine şu anda ulaşılamıyor. Daha sonra tekrar deneyin.');
        }
    };
}
module.exports = { MAX_BYTES, decodeImage, createHandler };
