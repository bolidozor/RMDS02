#!/bin/bash
#arecord -v --use-strftime -d720 -f dat -t wav -c2 /home/kaklik/Flyover_Svakov_%Y%m%d%H%M%S.wav >> /home/kaklik/record.log
arecord -v -D hw:1 -f dat -t wav -c2 --max-file-time 3600 --use-strftime /mnt/Svakov_HG/%Y/%m/%d/Radio_%Y%m%d%H%M%S.wav
