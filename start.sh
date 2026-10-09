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
# --- 5 KANALIN TAMAMI - CALISAN HALI, HICBIR KANAL SILINMEDI ---
# CAM1 - Türkülerle Türkiye + Nevşehir
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 > /tmp/cam1.log 2>&1 &

# CAM2 - Ulus Parkı + FM TV Türkü
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam2/playlist.m3u8 > /tmp/cam2.log 2>&1 &

# CAM3 - Kız Kulesi + TRT Türkü
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam3/playlist.m3u8 > /tmp/cam3.log 2>&1 &

# CAM4 - Hıdiv Kasrı + Radyo 7 Türkü (senin düzelttiğin kanal)
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

# CAM5 - Dragos + Radyo 7 Nostalji
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam5/playlist.m3u8 > /tmp/cam5.log 2>&1 &

echo "Tum kanallar baslatildi"
ls -lh /app/live/cam4/

python3 -m http.server 10000 --directory /app/live
