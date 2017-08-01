#!/bin/bash
pasuspender -- arecord -D hw:1,0 -v --buffer-time=500000 --use-strftime -d600 -f dat -t wav -c2 /mnt/ISS_Praha_%Y%m%d%H%M%S.wav >> /home/kaklik/SDR_record.log
