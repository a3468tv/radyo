import fs from 'fs';
import path from 'path';

export default async function handler(req, res) {
  let streamId = req.query.stream_id;
  if (!streamId && req.url) {
    const parts = req.url.split('/');
    streamId = parts[parts.length - 1];
  }
  if (!streamId) return res.status(400).send("Missing ID");
  if (Array.isArray(streamId)) streamId = streamId[0];

  const targetId = streamId.replace(/\.[^/.]+$/, "");
  let ytVideoId = targetId;

  // data.json'dan gerçek YouTube ID'yi bul
  try {
    const dataPath = path.join(process.cwd(), 'data', 'data.json');
    if (fs.existsSync(dataPath)) {
      const fileData = JSON.parse(fs.readFileSync(dataPath, 'utf8'));
      for (const s of fileData.series || []) {
        const ep = (s.episodes || []).find(e => String(e.id) === String(targetId));
        if (ep?.url) {
          const m = ep.url.match(/[?&]v=([^&]+)/);
          if (m) { ytVideoId = m[1]; break; }
        }
      }
    }
  } catch(e){}

  const videoUrl = `https://www.youtube.com/watch?v=${ytVideoId}`;

  // 1 - Cobalt API
  const cobaltList = ['https://api.cobalt.tools','https://co.wuk.sh','https://cobalt.canine.tools'];
  for (const api of cobaltList) {
    try {
      const r = await fetch(api, {
        method: 'POST',
        headers: { 'Accept':'application/json','Content-Type':'application/json' },
        body: JSON.stringify({ url: videoUrl, videoQuality: '720' }),
        signal: AbortSignal.timeout(4000)
      });
      if (r.ok) {
        const j = await r.json();
        if (j.url && j.url.includes('googlevideo')) {
          return res.redirect(302, j.url);
        }
      }
    } catch(e){ continue; }
  }

  // 2 - Invidious/Piped direkt mp4 - Vercel indirmeyecek, sadece yönlendirecek
  const invList = [
    `https://piped.video/latest_version?id=${ytVideoId}&itag=18`,
    `https://inv.nadeko.net/latest_version?id=${ytVideoId}&itag=18`,
    `https://invidious.flokinet.to/latest_version?id=${ytVideoId}&itag=18`
  ];
  for (const u of invList) {
    try {
      const h = await fetch(u, { method: 'HEAD', signal: AbortSignal.timeout(3000) });
      if (h.ok || h.status === 302 || h.status === 303) {
        return res.redirect(302, u);
      }
    } catch(e){ continue; }
  }

  // 3 - Son çare
  return res.redirect(302, videoUrl);
}
