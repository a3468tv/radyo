#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5
mkdir -p /app/fonts

# Fontu garanti indir
apt-get update -qq && apt-get install -y -qq fonts-dejavu-core wget > /dev/null 2>&1
cp /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf /app/fonts/ 2>/dev/null || true
if [! -f /app/fonts/DejaVuSans.ttf ]; then
  wget -q -O /app/fonts/DejaVuSans.ttf https://github.com/dejavu-fonts/dejavu-fonts/raw/master/ttf/DejaVuSans.ttf
fi
ls -lh /app/fonts/DejaVuSans.ttf

echo "Radyo 7 Turku - Basliyor" > /app/live/cam4/nowplaying.txt
pip install -q requests > /dev/null 2>&1

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
        return f"{artist} - {title}"
    except Exception as e:
        print(e)
        return "Radyo 7 Turku - Canli"
while True:
    t=get_title()
    # Turkce karakteri bozmasin diye ASCII'ye cevir
    t_safe = t.replace('İ','I').replace('ı','i').replace('Ğ','G').replace('ğ','g').replace('Ş','S').replace('ş','s').replace('Ç','C').replace('ç','c').replace('Ö','O').replace('ö','o').replace('Ü','U').replace('ü','u')
    open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8").write(t_safe)
    open("/app/live/cam4/nowplaying.json","w",encoding="utf-8").write(json.dumps({"nowplaying":t},ensure_ascii=False))
    print(f"[CAM4] {t_safe}",flush=True)
    time.sleep(10)
PY

python3 /app/get_nowplaying.py &
sleep 4
cat /app/live/cam4/nowplaying.txt

# DIGER 4 KANAL - COPY - DOKUNMADIM
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam2/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam3/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam5/playlist.m3u8 &

# CAM4 - ILK CALISAN HALI - YAZI BUYUK
rm -rf /app/live/cam4/*.ts /app/live/cam4/*.m3u8 2>/dev/null; sleep 1
ffmpeg -loglevel info -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" -map 0:v:0 -map 1:a:0 -vf "drawtext=fontfile=/app/fonts/DejaVuSans.ttf:textfile=/app/live/cam4/nowplaying.txt:reload=1:fontcolor=white:fontsize=44:box=1:boxcolor=black@0.7:boxborderw=15:x=(w-text_w)/2:y=h-th-60" -c:v libx264 -preset ultrafast -tune zerolatency -b:v 2000k -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam4/seg_%03d.ts" /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

sleep 8
cat /tmp/cam4.log | tail -n 60
ls -lh /app/live/cam4/

python3 -m http.server 10000 --directory /app/live
