#!/usr/bin/env bash

[[ $# -ne 2 ]] && echo "Usage: ./sync.sh /path/to/folder observatory_name" && exit 1

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
#exec > >(tee "$1"/logfile)

# Also redirect stderr
#exec 2>&1

# 9 min delay between resync
FREQUENCY=540

TIDYUP="$(pwd)/tidyup.sh"
RSYNC="$(pwd)/upload.sh"

DEFAULT="\033[00m"
RED="\033[01;31m"
BLUE="\033[01;36m"

function info() {
    echo -en "$BLUE"; echo -n $1; echo -e "$DEFAULT"
}
function error() {
    echo -en "$RED"; echo -n $1; echo -e "$DEFAULT"
}

function syncdir() {
    EXIT=1
    i=1
#    while [ $EXIT -ne 0 ]; do
	info "Trying to sync $1; $2; $3; $4"
	"$RSYNC" $1 $2 $3 $4
	EXIT=$?
	[ $EXIT -ne 0 ] && error "sync failed"
	let i++
#    done 
    return $EXIT
}

# Sort files
# Mask 
function tidyup() {
    info "sorting $1"
    "$TIDYUP" $1
    if [ "$?" -ne 0 ]; then
	error "sorting failed, please send logfile.txt"
	return 1
    fi
    return 0
}

# Test public key authentication
function sshtest() {
    ./test.sh $1
    if [ "$?" -eq 0 ]; then
	info "Authentication works"
	return 0
    else
	error "Authentication does not work"
	return 1
    fi
}

# parameters $1=LocalPathToData $2=ObservatoryName
function main() {
   # start timer
    start_time=`date +%s`
    
#    OLD=$LAST
#    OLD_HOUR=$LAST_HOUR
    # sort
    tidyup $1 || error "Sort failed, please analyze logfile.txt ."
    
    
    if [ -f "$1"/LAST ]
    then
    
      # read last processed day
#      read LAST < "$1"/LAST
#      read LAST_HOUR < "$1"/capture/LAST
  
      # sync last updated folders  
      syncdir $2 audio/"$LAST" -a
      syncdir $2 capture/"$LAST_HOUR" -a
      syncdir $2 data/"$LAST" -a
      syncdir $2 data --dirs --delete 
  
      # days changed, sync whole yesterday too
      if [ "$LAST" != "$OLD" ]
      then 
        info "syncing yesterday"
        syncdir $2 audio/"$OLD" -a
        syncdir $2 capture/"$OLD" -a
        syncdir $2 data/"$OLD" -a
      else
        # hours changed? sync previous hour too?
        if [ "$LAST_HOUR" != "$OLD_HOUR" ]
        then 
          info "syncing previous hour"
          syncdir $2 capture/"$OLD_HOUR" -a
        fi
      fi
    fi
    
    # end timer
    end_time=`date +%s`
    ELAPSED=`expr $end_time - $start_time`
    info "execution time was $ELAPSED s"  
    date
}

# Check if we can connect, otherwise terminate
info "Checking connection to the server"
sshtest $2 || exit 1

# Change working directory
cd $1

# first sort
info "Tidyup..."
tidyup $1 || error "Sorted, please analyze logfile.txt ."
    
# first sync 
info "Doing complete sync"
syncdir $2 . -a

    if [ -f "$1"/LAST ]
    then
      read LAST < "$1"/LAST
    else
      LAST="."
    fi

    if [ -f "$1"/capture/LAST ]
    then
      read LAST_HOUR < "$1"/capture/LAST
    else
      LAST_HOUR="."
    fi


# Periodically tidy up and do incremental sync
while :
do
    OLD=$LAST
    OLD_HOUR=$LAST_HOUR
    # read last processed day/hour
    read LAST < "$1"/LAST
    read LAST_HOUR < "$1"/capture/LAST

    main $1 $2 2>&1 | tee "$1"/logfile

    # save only tail from logfile
    tail -n 1000 "$1"/logfile > "$1"/logfile.txt
    rm "$1"/logfile
    syncdir $2 . --dirs --delete > /dev/null 2>&1

    # wait for a next syncing period
    sleep $FREQUENCY
done