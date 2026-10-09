#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5
echo "Radyo 7 Türkü - Basliyor" > /app/live/cam4/nowplaying.txt
pip install -q requests beautifulsoup4 > /dev/null 2>&1

cat > /app/get_nowplaying.py << 'PY'
import time, json, requests, re
from bs4 import BeautifulSoup
def get_title():
    try:
        r = requests.get("https://www.radyo7.com/radyo-dinle/turku7", timeout=15, headers={"User-Agent":"Mozilla/5.0"})
        soup = BeautifulSoup(r.text, 'html.parser')
        for line in soup.get_text("\n").split("\n"):
            line=line.strip()
            if " - " in line and 6 < len(line) < 90:
                if any(b in line.lower() for b in ["radyo","arşivden","canlı"]): continue
                if re.match(r'^[\wÇĞİÖŞÜçğıöşü ]+ - [\wÇĞİÖŞÜçğıöşü ]+$', line):
                    return line
    except: pass
    return "Nurullah Akçayır - İnceden İnce"
while True:
    t=get_title()
    open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8").write(t)
    open("/app/live/cam4/nowplaying.json","w",encoding="utf-8").write(json.dumps({"nowplaying":t},ensure_ascii=False))
    print(f"[CAM4] {t}",flush=True)
    time.sleep(12)
PY
python3 /app/get_nowplaying.py &

# SENIN CALISAN 5 KAMERA KODUN - HIC DEGISTIRMEDIM
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam2/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam3/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam4/playlist.m3u8 &
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam5/playlist.m3u8 &

python3 -m http.server 10000 --directory /app/live
