#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5
mkdir -p /app/fonts
echo "=== TV VERSIYON 480p ==="
apt-get update -qq && apt-get install -y -qq fonts-dejavu-core > /dev/null 2>&1
cp /usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf /app/fonts/font.ttf 2>/dev/null || cp /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf /app/fonts/font.ttf

echo "Radyo 7 Turku" > /app/live/cam4/nowplaying.txt
echo '{"nowplaying":"Radyo 7 Turku"}' > /app/live/cam4/nowplaying.json
chmod 666 /app/live/cam4/nowplaying.txt

pip install -q requests > /dev/null 2>&1

cat > /app/get_nowplaying.py << 'PY'
import time, json, requests, os
def get_title():
    try:
        r = requests.get("https://cdn.kanal7.com/radyo7/json/turku7.json", timeout=10, headers={"User-Agent":"Mozilla/5.0"})
        data = r.json()
        s = data['songs'][1]
        a = s.get('artist','').strip()
        t = s.get('title','').strip()
        if 'Anons' in a or 'Reklam' in a:
            s = data['songs'][0]
            a = s.get('artist','').strip()
            t = s.get('title','').strip()
        full = f"{a} - {t}"
        safe = full.replace('İ','I').replace('ı','i').replace('Ğ','G').replace('ğ','g').replace('Ş','S').replace('ş','s').replace('Ç','C').replace('ç','c').replace('Ö','O').replace('ö','o').replace('Ü','U').replace('ü','u')
        return safe
    except:
        return "Radyo 7 Turku"
while True:
    safe = get_title()
    try:
        open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8").write(safe)
        open("/app/live/cam4/nowplaying.json","w",encoding="utf-8").write(json.dumps({"nowplaying":safe},ensure_ascii=False))
        os.chmod("/app/live/cam4/nowplaying.txt",0o666)
        print(f"[CAM4] {safe}",flush=True)
    except: pass
    time.sleep(10)
PY

python3 /app/get_nowplaying.py &
sleep 3

# 1-2-3-5 COPY (hafif)
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 > /tmp/cam1.log 2>&1 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list /app/live/cam2/playlist.m3u8 > /tmp/cam2.log 2>&1 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list /app/live/cam3/playlist.m3u8 > /tmp/cam3.log 2>&1 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list /app/live/cam5/playlist.m3u8 > /tmp/cam5.log 2>&1 &

# CAM4 - TV ICIN YAKILI - 854x480 - COK DAHA AZ RAM
rm -f /app/live/cam4/*.ts /app/live/cam4/*.m3u8
sleep 1
ffmpeg -loglevel info -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" -map 0:v:0 -map 1:a:0 -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,drawtext=fontfile=/app/fonts/font.ttf:textfile=/app/live/cam4/nowplaying.txt:reload=1:fontcolor=white:fontsize=28:box=1:boxcolor=black@0.7:boxborderw=10:x=(w-text_w)/2:y=h-th-20" -c:v libx264 -preset veryfast -b:v 800k -maxrate 800k -bufsize 1600k -g 50 -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam4/seg_%03d.ts" /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

sleep 12
echo "=== CAM4 LOG SON 80 SATIR ==="
tail -n 80 /tmp/cam4.log
echo "=== DOSYALAR ==="
ls -lh /app/live/cam4/

python3 -m http.server 10000 --directory /app/live
