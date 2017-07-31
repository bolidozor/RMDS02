#!/usr/bin/env bash
#
#  sync directory to server
#
#  this script should not be called manually

echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

[[ "$#" < 1 ]] && echo "Please provide directory to upload" && exit 1

# debug
set -x

UPDIR="$2"
STATIONNAME=${PWD##*/}
OBSERVATORYNAME="$1"

#echo "$1 ; $2 ; $3 ; $4" >> /media/sd/meteors/debug.log

# if exclude-list.txt is present, use it
# could as well be changed for rsync -q, but this is more clear
if [[ -f exclude-list.txt ]]
    then
    rsync -vvtz $3 $4 "$UPDIR"/ --exclude-from='exclude-list.txt' "$OBSERVATORYNAME"@space.astro.cz:/storage/bolidozor/"$OBSERVATORYNAME"/"$STATIONNAME"/"$UPDIR"
    else
    rsync -vvtz $3 $4 "$UPDIR"/ "$OBSERVATORYNAME"@space.astro.cz:/storage/bolidozor/"$OBSERVATORYNAME"/"$STATIONNAME"/"$UPDIR"
fi
