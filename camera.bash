ffmpeg -y \
  -f v4l2 -re -i /dev/video0 \
  -vcodec libx264 -s 1280x720 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -g 30 -refs 4 -use_wallclock_as_timestamps 1 -b:v 100k -qp 35 -window_size 9000 -movflags frag_keyframe+empty_moov -f flv rtmp://localhost/live/webcam_h \
  -vcodec libx264 -s 640x360 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -g 30 -refs 4 -use_wallclock_as_timestamps 1 -b:v 100k -qp 35 -window_size 9000 -movflags frag_keyframe+empty_moov -f flv rtmp://localhost/live/webcam_m \
  -vcodec libx264 -s 320x180 -pix_fmt yuv420p -preset ultrafast -tune zerolatency -g 30 -refs 4 -use_wallclock_as_timestamps 1 -b:v 100k -qp 35 -window_size 9000 -movflags frag_keyframe+empty_moov -f flv rtmp://localhost/live/webcam_l \