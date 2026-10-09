#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5
echo "Radyo 7 Türkü" > /app/live/cam4/nowplaying.txt
echo '{"nowplaying":"Radyo 7 Türkü"}' > /app/live/cam4/nowplaying.json

pip install -q requests > /dev/null 2>&1
apt-get update -qq && apt-get install -y -qq fonts-dejavu-core > /dev/null 2>&1
ls /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
ls -lh /app/live/cam4/

cat > /app/get_nowplaying.py << 'PY'
import time, json, requests
def get_title():
    try:
        r = requests.get("https://cdn.kanal7.com/radyo7/json/turku7.json", timeout=10, headers={"User-Agent":"Mozilla/5.0"})
        data = r.json()
        song = data['songs'][1]
        artist = song.get('artist','').strip()
        title = song.get('title','').strip()
        if 'Anons' in artist or 'Reklam' in artist:
            song = data['songs'][0]
            artist = song.get('artist','').strip()
            title = song.get('title','').strip()
        full = f"{artist} - {title}"
        if len(full) > 5:
            return full
    except Exception as e:
        print(f"Hata: {e}", flush=True)
    return "Radyo 7 Türkü - Canlı"
while True:
    t = get_title()
    open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8").write(t)
    open("/app/live/cam4/nowplaying.json","w",encoding="utf-8").write(json.dumps({"nowplaying":t}, ensure_ascii=False))
    print(f"[CAM4] {t}", flush=True)
    time.sleep(10)
PY

python3 /app/get_nowplaying.py &
sleep 3
cat /app/live/cam4/nowplaying.txt

# CAM1,2,3,5 COPY (dokunmadim)
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 > /tmp/cam1.log 2>&1 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam2/playlist.m3u8 > /tmp/cam2.log 2>&1 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam3/playlist.m3u8 > /tmp/cam3.log 2>&1 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam5/playlist.m3u8 > /tmp/cam5.log 2>&1 &

# CAM4 - BUYUK FONT EKRAN USTU - DOGRUDAN SISTEM FONTU
rm -rf /app/live/cam4/*.ts /app/live/cam4/*.m3u8
sleep 1
ffmpeg -loglevel info -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" \
-map 0:v:0 -map 1:a:0 \
-vf "drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:textfile=/app/live/cam4/nowplaying.txt:reload=1:fontcolor=white:fontsize=44:box=1:boxcolor=black@0.75:boxborderw=20:x=(w-text_w)/2:y=h-th-80" \
-c:v libx264 -preset ultrafast -tune zerolatency -b:v 2000k -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam4/seg_%03d.ts" /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

sleep 8
echo "--- CAM4 LOG ---"
cat /tmp/cam4.log | tail -n 100
echo "--- FILES ---"
ls -lh /app/live/cam4/

python3 -m http.server 10000 --directory /app/live
