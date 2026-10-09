#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5
echo "Radyo 7 Türkü - Canlı" > /app/live/cam4/nowplaying.txt
echo '{"nowplaying":"Radyo 7 Türkü - Canlı"}' > /app/live/cam4/nowplaying.json

mkdir -p /app/fonts
wget -q -O /app/fonts/DejaVuSans.ttf https://github.com/dejavu-fonts/dejavu-fonts/raw/master/ttf/DejaVuSans.ttf || cp /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf /app/fonts/ 2>/dev/null || true

# --- Now Playing çekici ---
cat > /app/get_nowplaying.py << 'PY'
import time, json, re, requests, subprocess
def get_title():
    try:
        r = requests.get("https://www.radyo7.com/radyo-dinle/turku7", timeout=10, headers={"User-Agent":"Mozilla/5.0"})
        m = re.search(r'StreamTitle.*?([A-ZÇĞİÖŞÜ].*?)<', r.text)
        if m: return m.group(1).strip()
        # icecast json dene
        r2 = requests.get("https://moondigitaledge2.radyotvonline.net/status-json.xsl", timeout=10)
        j = r2.json()
        for src in j.get("icestats",{}).get("source",[]):
            if "turku" in src.get("listenurl",""):
                if src.get("title"): return src["title"]
    except Exception as e:
        print("hata", e)
    return "Radyo 7 Türkü - Canlı Yayın"

while True:
    t = get_title()
    try:
        open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8").write(t)
        open("/app/live/cam4/nowplaying.json","w",encoding="utf-8").write(json.dumps({"nowplaying":t}, ensure_ascii=False))
        print("CAM4 NOW:", t, flush=True)
    except: pass
    time.sleep(10)
PY
python3 /app/get_nowplaying.py &

sleep 2

# 1 - TURKULERLE TURKIYE + NEVSEHIR
ffmpeg -loglevel info -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 > /tmp/cam1.log 2>&1 &

# 4 - HIDIV KASRI + RADYO 7 TURKU - FIXED
ffmpeg -loglevel info -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -user_agent "Mozilla/5.0" -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" \
-map 0:v:0 -map 1:a:0 \
-vf "drawtext=fontfile=/app/fonts/DejaVuSans.ttf:textfile=/app/live/cam4/nowplaying.txt:reload=1:fontcolor=white:fontsize=24:box=1:boxcolor=black@0.6:boxborderw=10:x=20:y=h-th-50" \
-c:v libx264 -preset ultrafast -tune zerolatency -b:v 1500k -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

# diğerleri aynı kalsın test için kapatıyorum, önce cam4 gelsin
# cam2, cam3, cam5'i sonra açarsın

echo "Loglar: tail -f /tmp/cam4.log"
python3 -m http.server 10000 --directory /app/live
