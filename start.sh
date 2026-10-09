#!/bin/sh
mkdir -p /app/live/cam4
echo "Radyo 7 Türkü - Basliyor" > /app/live/cam4/nowplaying.txt
rm -f /app/live/cam4/playlist.m3u8

# Font garantile
apt-get update -qq && apt-get install -y -qq fonts-dejavu-core > /dev/null 2>&1 || true
mkdir -p /app/fonts
cp /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf /app/fonts/ 2>/dev/null || wget -q -O /app/fonts/DejaVuSans.ttf https://github.com/dejavu-fonts/dejavu-fonts/raw/master/ttf/DejaVuSans.ttf || true
ls -lh /app/fonts/

cat > /app/get_nowplaying.py << 'PY'
import time, json, requests, re
while True:
    try:
        r = requests.get("https://www.radyo7.com/radyo-dinle/turku7", timeout=10, headers={"User-Agent":"Mozilla/5.0"})
        title = "Radyo 7 Türkü"
        m = re.search(r'<title>(.*?)</title>', r.text)
        if m: title = m.group(1)[:80]
        open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8").write(title)
        print("NOW:", title, flush=True)
    except Exception as e:
        print("now err", e, flush=True)
    time.sleep(15)
PY
python3 /app/get_nowplaying.py &

echo "=== CAM4 TEST BASLIYOR, LOG /tmp/cam4.log ==="
# Önce sadece ses + test görüntü ile dene - kamera linkini sonra ekleyeceğiz
ffmpeg -loglevel info -re -f lavfi -i "testsrc=size=1280x720:rate=25" -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" \
-map 0:v:0 -map 1:a:0 \
-vf "drawtext=fontfile=/app/fonts/DejaVuSans.ttf:textfile=/app/live/cam4/nowplaying.txt:reload=1:fontcolor=white:fontsize=28:box=1:boxcolor=black@0.6:x=20:y=h-th-50,drawtext=fontfile=/app/fonts/DejaVuSans.ttf:text='HIDIV KASRI - RADYO 7 TURKU':fontcolor=yellow:fontsize=24:x=20:y=20:box=1:boxcolor=black@0.6" \
-c:v libx264 -preset ultrafast -tune zerolatency -b:v 1200k -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam4/seg_%03d.ts" /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

sleep 5
ls -lh /app/live/cam4/
cat /tmp/cam4.log | tail -n 100

python3 -m http.server 10000 --directory /app/live
