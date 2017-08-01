#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#arecord -v --use-strftime -d720 -f dat -t wav -c2 /home/kaklik/Flyover_Svakov_%Y%m%d%H%M%S.wav >> /home/kaklik/record.log
#arecord -v -f dat -t wav -c2 --max-file-time 3600 --use-strftime /mnt/Svakov/%Y/%m/%d/Radio_%Y%m%d%H%M%S.wav
recordfile=/media/Radio_zaloha___/Svakov_HG/$(date +Radio_HG_%Y%m%d%H%M%S).wav
#screen jack_capture -V -d 36 -c 2 -p alsa_in:capture* --filename  $recordfile
#screen jack_capture -V -c 2 -p alsa_in:capture* --filename  $recordfile
jack_capture -V -d 3605 -c 2 -p alsa_in:capture_1 -p alsa_in:capture_2 --filename  $recordfile &
