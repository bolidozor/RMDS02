#!/usr/bin/env bash
#
#  sync directory to server
#
#  this script should not be called manually

[[ "$#" -ne 1 ]] && echo "Please provide directory to upload" && exit 1

# debug
set -x

#cd `dirname $1`
#UPDIR=`basename $1`
UPDIR="$1"

# if exclude-list.txt is present, use it
# could as well be changed for rsync -q, but this is more clear
if [[ -f exclude-list.txt ]]
    then
    rsync -avtz "$UPDIR"/ --exclude-from='exclude-list.txt' meteor@neptun.avc-cvut.cz:data/"$UPDIR"
    else
    rsync -avtz "$UPDIR"/ meteor@neptun.avc-cvut.cz:data/"$UPDIR"
fi
