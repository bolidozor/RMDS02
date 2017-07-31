#!/usr/bin/env bash

[[ $# -ne 1 ]] && echo "Usage: ./sync.sh /path/to/folder" && exit 1

# Redirect stdout ( > ) into a named pipe ( >() ) running "tee"
exec > >(tee logfile.txt)

# Also redirect stderr
exec 2>&1

FREQUENCY=60

TIDYUP="./tidyup.sh"
RSYNC="./upload.sh"

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
    while [ $EXIT -ne 0 ]; do
	info "Trying to sync $1, try number $i"
	"$RSYNC" "$1"
	EXIT=$?
	[ $EXIT -ne 0 ] && error "sync failed"
	let i++
    done 
    return $EXIT
}

# Sort files
# Mask 
function tidyup() {
    info "sorting $1"
    "$TIDYUP" $1
    if [ "$?" -ne 0 ]; then
	error "sorting failed, please send logfile.txt to toxygen1@gmail.com"
	return 1
    fi
    return 0
}

# Test public key authentication
function sshtest() {
    ./test.sh
    if [ "$?" -eq 0 ]; then
	info "Authentication works"
	return 0
    else
	error "Authentication does not work"
	return 1
    fi
}

# Check if we can connect, otherwise terminate
sshtest || exit 1

# Change working directory
cd $1

# reset counter
HOURCOUNT=24

# Periodically tidy up and do incremental sync
while :
do
    # start timer
    start_time=`date +%s`
    
    # sort
    tidyup . || error "Sort failed, please send logfile.txt to toxygen1@gmail.com"
    
    # increase counter every hour
    # if 24 hour mark is hit, do daily sync
    if [[ "$HOURCOUNT" -eq 24 ]]
    then 
	info "Doing complete sync"
	syncdir .
	HOURCOUNT=0
        # next line is important for the first run of the loop
	read LAST < LAST
    fi
    let HOURCOUNT++

    # read last processed day
    OLD="$LAST"
    read LAST < LAST

    # sync last updated folder
    syncdir "$LAST"

    # days changed, sync yesterday too
    [[ "$LAST" != "$OLD" ]] && info "syncing yesterday" && syncdir "$OLD" 

    tail -n 1000 logfile.txt > tmp.txt
    mv tmp.txt logfile.txt

    # end timer
    end_time=`date +%s`
    ELAPSED=`expr $end_time - $start_time`
    info "execution time was $ELAPSED s"

    # if last sync took less than TIME, sleep to make up 1 hour
    [[ $ELAPSED -lt $FREQUENCY ]] && sleep `expr $FREQUENCY - $ELAPSED`
done