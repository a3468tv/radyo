#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5

# --- HIDIV KASRI İÇİN ŞU AN ÇALAN TÜRKÜYÜ ÇEKEN ARKA PLAN SCRIPTİ ---
cat > /app/get_nowplaying.py << 'PY'
import time, json, re, requests

def get_turku7_now():
    try:
        # 1. Yöntem: Radyo7 sayfasından çek
        r = requests.get("https://www.radyo7.com/radyo-dinle/turku7", timeout=10, headers={"User-Agent":"Mozilla/5.0"})
        # sayfada genellikle "nowPlaying": "Eser - Sanatçı" gibi bir şey var
        m = re.search(r'"nowPlaying"\s*:\s*"([^"]+)"', r.text)
        if m:
            return m.group(1)
        m2 = re.search(r'Simdi Caliyor[^<]*<[^>]*>([^<]+)', r.text, re.I)
        if m2:
            return m2.group(1).strip()
        # 2. Yöntem: Icecast metadata
        r2 = requests.get("https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8", timeout=10)
        # Eğer başlıkta gelmezse fallback
    except:
        pass
    try:
        # Direkt stream başlığından icy title al
        import subprocess
        out = subprocess.check_output(
            ["ffprobe","-v","quiet","-print_format","json","-show_format","https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8"],
            timeout=10
        )
        j = json.loads(out)
        return j.get("format",{}).get("tags",{}).get("StreamTitle","Radyo 7 Türkü - Canlı")
    except:
        return "Radyo 7 Türkü - Canlı Yayın"

while True:
    title = get_turku7_now()
    # Dosyalara yaz - HLS klasörüne
    with open("/app/live/cam4/nowplaying.txt","w",encoding="utf-8") as f:
        f.write(title)
    with open("/app/live/cam4/nowplaying.json","w",encoding="utf-8") as f:
        json.dump({"channel":"RADYO 7 TURKU + HIDIV KASRI","nowplaying":title,"time":time.strftime("%H:%M:%S")}, f, ensure_ascii=False)
    print(f"[CAM4] {title}")
    time.sleep(15)
PY

# Python arka planda çalışsın
python3 /app/get_nowplaying.py &

# Fontu indir (drawtext için)
mkdir -p /app/fonts
wget -q -O /app/fonts/DejaVuSans.ttf https://github.com/dejavu-fonts/dejavu-fonts/raw/master/ttf/DejaVuSans.ttf || true

# 1 - TURKULERLE TURKIYE + NEVSEHIR KAMERASI
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam1/playlist.m3u8 &

# 2 - RADYO TURKU + ULUS PARKI
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam2/playlist.m3u8 &

# 3 - TRT TURKU + KIZ KULESI
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam3/playlist.m3u8 &

# 4 - RADYO 7 TURKU + HIDIV KASRI (ŞU AN ÇALAN YAZILI)
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" \
-map 0:v:0 -map 1:a:0 \
-vf "drawtext=fontfile=/app/fonts/DejaVuSans.ttf:textfile=/app/live/cam4/nowplaying.txt:reload=1:fontcolor=white:fontsize=28:box=1:boxcolor=black@0.6:boxborderw=10:x=20:y=h-th-60,drawtext=fontfile=/app/fonts/DejaVuSans.ttf:text='HIDIV KASRI - RADYO 7 TURKU':fontcolor=yellow:fontsize=24:box=1:boxcolor=black@0.6:boxborderw=8:x=20:y=20" \
-c:v libx264 -preset veryfast -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam4/playlist.m3u8 &

# 5 - RADYO 7 NOSTALJI + DRAGOS
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 96k -f hls -hls_time 6 -hls_list_size 10 -hls_flags delete_segments+append_list /app/live/cam5/playlist.m3u8 &

python3 -m http.server 10000 --directory /app/live
