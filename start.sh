#!/bin/sh
mkdir -p /app/live/cam1 /app/live/cam2 /app/live/cam3 /app/live/cam4 /app/live/cam5
mkdir -p /app/fonts
echo "=== SABIT YAZILI TV VERSIYON ==="
apt-get update -qq && apt-get install -y -qq fonts-dejavu-core > /dev/null 2>&1
cp /usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf /app/fonts/font.ttf 2>/dev/null || cp /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf /app/fonts/font.ttf

# 5 KANALIN HEPSI YAZILI - 854x480 - TV UYUMLU - COK HAFIF
# CAM1 - NEVSEHIR KALESI
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://belsis.nevsehir.bel.tr/hls/live/X8o7aXINdylwjstgvjyPjSJn/index.m3u8" -i "https://moondigitaledge.radyotvonline.net/turkulerleturkiye/playlist.m3u8" -map 0:v:0 -map 1:a:0 -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,drawtext=fontfile=/app/fonts/font.ttf:text='TURKULERLE TURKIYE':fontcolor=yellow:fontsize=22:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=20,drawtext=fontfile=/app/fonts/font.ttf:text='NEVSEHIR KALESI - CANLI':fontcolor=white:fontsize=20:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=60" -c:v libx264 -preset veryfast -b:v 800k -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam1/seg_%03d.ts" /app/live/cam1/playlist.m3u8 > /tmp/cam1.log 2>&1 &

# CAM2 - ULUS PARKI
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/ulusparki.stream/playlist.m3u8" -i "https://yayin.turkhosted.com/4591/stream" -map 0:v:0 -map 1:a:0 -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,drawtext=fontfile=/app/fonts/font.ttf:text='RADYO TURKU':fontcolor=yellow:fontsize=22:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=20,drawtext=fontfile=/app/fonts/font.ttf:text='ULUS PARKI - CANLI':fontcolor=white:fontsize=20:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=60" -c:v libx264 -preset veryfast -b:v 800k -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam2/seg_%03d.ts" /app/live/cam2/playlist.m3u8 > /tmp/cam2.log 2>&1 &

# CAM3 - KIZ KULESI
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/kizkulesi.stream/playlist.m3u8" -i "https://rd-trtturku.medya.trt.com.tr/master_128.m3u8" -map 0:v:0 -map 1:a:0 -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,drawtext=fontfile=/app/fonts/font.ttf:text='TRT TURKU':fontcolor=yellow:fontsize=22:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=20,drawtext=fontfile=/app/fonts/font.ttf:text='KIZ KULESI - CANLI':fontcolor=white:fontsize=20:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=60" -c:v libx264 -preset veryfast -b:v 800k -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam3/seg_%03d.ts" /app/live/cam3/playlist.m3u8 > /tmp/cam3.log 2>&1 &

# CAM4 - HIDIV KASRI + RADYO 7 TURKU (SENIN ISTEDIGIN)
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/hidivkasri.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7turku/playlist.m3u8" -map 0:v:0 -map 1:a:0 -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,drawtext=fontfile=/app/fonts/font.ttf:text='RADYO 7 TURKU':fontcolor=yellow:fontsize=24:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=20,drawtext=fontfile=/app/fonts/font.ttf:text='HIDIV KASRI - CANLI':fontcolor=white:fontsize=22:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=60" -c:v libx264 -preset veryfast -b:v 800k -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam4/seg_%03d.ts" /app/live/cam4/playlist.m3u8 > /tmp/cam4.log 2>&1 &

# CAM5 - DRAGOS
ffmpeg -reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 30 -i "https://kamerayayin.ibb.istanbul/turistikcam/dragos.stream/playlist.m3u8" -i "https://moondigitaledge2.radyotvonline.net/radyo7nostalji/playlist.m3u8" -map 0:v:0 -map 1:a:0 -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2,drawtext=fontfile=/app/fonts/font.ttf:text='RADYO 7 NOSTALJI':fontcolor=yellow:fontsize=22:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=20,drawtext=fontfile=/app/fonts/font.ttf:text='DRAGOS TEPE - CANLI':fontcolor=white:fontsize=20:box=1:boxcolor=black@0.7:boxborderw=8:x=20:y=60" -c:v libx264 -preset veryfast -b:v 800k -c:a aac -b:a 64k -f hls -hls_time 6 -hls_list_size 6 -hls_flags delete_segments+append_list -hls_segment_filename "/app/live/cam5/seg_%03d.ts" /app/live/cam5/playlist.m3u8 > /tmp/cam5.log 2>&1 &

sleep 15
echo "=== LOGS ===" && ls -lh /app/live/cam*/ | head -n 50
python3 -m http.server 10000 --directory /app/live
