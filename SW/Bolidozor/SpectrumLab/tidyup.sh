#!/usr/bin/env bash
#
# tidyup.sh
#
# This script will sort create organized directory structure
# from observation files in one directory.
#
# Takes one argument: path to the directory
#
# Returns 0 if sorting succeeds
# Returns 1 if there are no files to sort
# Returns >1 in case of error
#
# before: 
#
# |
# | 20131214214014084_SVAKOV-R2_met.jpg
# | 20131214214124184_SVAKOV-R2_met.jpg
# | 20131224214124184_SVAKOV-R2_met.jpg
# | .
# | .
# | .
#
# after:
#
# |
# |- SVAKOV-R2             <- observatory
# |    |- 2013             <- year
# |         |- 12             <- month
# |             |- 14             <- day
# |                 |- 21             <- hour
# |                 |   |- 20131214214014084_SVAKOV-R2_met.jpg
# |                 |   |- 20131214214124184_SVAKOV-R2_met.jpg
# |                 |
# |                 |- 22
# |                     |- 20131224214124184_SVAKOV-R2_met.jpg
# |               
# .
# .
# .
#
#
# filename format must be as 20131214214014084_SVAKOV-R2_met.jpg

DELIM="_"
SLASH="/"
LAST=""


# turn on debug
set -x

# none or 1 argument allowed
[[ "$#" -ne 1 ]] && echo "Wrong number of arguments ($#)" && exit 1

# directory in which to sort must exists
[[ ! -d "$1" ]] && echo "Directory doesn't exist" && exit 1

# captured images
cd "$1"/capture

# if there are no files with $EXT extension in the directory then quit
EXT="jpg"
ls -f *."$EXT" > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in *."$EXT"; do
	echo "processing " $i
	OBSERVATORY=`echo $i | cut -d $DELIM -f2`
	OBSERVATORY=`echo "$OBSERVATORY" | cut -d "." -f1`
	
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f1`
	YEAR=`echo "$TIMESTAMP" | cut -c 1-4`
	MONTH=`echo "$TIMESTAMP" | cut -c 5-6`
	DAY=`echo "$TIMESTAMP" | cut -c 7-8`
	HOUR=`echo "$TIMESTAMP" | cut -c 9-10`
	
    # observatory / year / month / day / hour
	DAYDIR="$YEAR$SLASH$MONTH$SLASH$DAY$SLASH$HOUR"
	
    # create directory with observatory name, year, month and day if hasn't existed before
	[[ -d "$DAYDIR" ]] || mkdir -p "$DAYDIR" 
	
    # check if directory really exists (if fs is full it might not be created)
	[[ -d "$DAYDIR" ]] && mv "$i" "$DAYDIR"
    
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY$SLASH$HOUR" > LAST
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > "$1"/LAST
    done
else
    echo "No .""$EXT"" files to sort"
fi

#captured sounds
cd "$1"/audio

EXT="wav"
ls -f *."$EXT" > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in *."$EXT"; do
	echo "processing " $i
	OBSERVATORY=`echo $i | cut -d $DELIM -f2`
	OBSERVATORY=`echo "$OBSERVATORY" | cut -d "." -f1`
	
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f1`
	YEAR=`echo "$TIMESTAMP" | cut -c 1-4`
	MONTH=`echo "$TIMESTAMP" | cut -c 5-6`
	DAY=`echo "$TIMESTAMP" | cut -c 7-8`
	HOUR=`echo "$TIMESTAMP" | cut -c 9-10`
	
    # observatory / year / month / day / hour
	DAYDIR="$YEAR$SLASH$MONTH$SLASH$DAY"
	
    # create directory with observatory name, year, month and day if hasn't existed before
	[[ -d "$DAYDIR" ]] || mkdir -p "$DAYDIR" 
	
    # check if directory really exists (if fs is full it might not be created)
	[[ -d "$DAYDIR" ]] && mv "$i" "$DAYDIR"
    
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > LAST
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > "$1"/LAST
    done
else
    echo "No .""$EXT"" files to sort"
fi

EXT="aux"
ls -f *."$EXT" > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in *."$EXT"; do
	echo "processing " $i
	OBSERVATORY=`echo $i | cut -d $DELIM -f2`
	OBSERVATORY=`echo "$OBSERVATORY" | cut -d "." -f1`
	
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f1`
	YEAR=`echo "$TIMESTAMP" | cut -c 1-4`
	MONTH=`echo "$TIMESTAMP" | cut -c 5-6`
	DAY=`echo "$TIMESTAMP" | cut -c 7-8`
	HOUR=`echo "$TIMESTAMP" | cut -c 9-10`
	
    # observatory / year / month / day / hour
	DAYDIR="$YEAR$SLASH$MONTH$SLASH$DAY"
	
    # create directory with observatory name, year, month and day if hasn't existed before
	[[ -d "$DAYDIR" ]] || mkdir -p "$DAYDIR" 
	
    # check if directory really exists (if fs is full it might not be created)
	[[ -d "$DAYDIR" ]] && mv "$i" "$DAYDIR"
    
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > LAST
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > "$1"/LAST
    done
else
    echo "No .""$EXT"" files to sort"
fi

#metadata for Bolidozor
cd "$1"/data

EXT="dat"
ls -f *."$EXT" > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in $(find *."$EXT" -maxdepth 1 -mmin +59); do
	echo "processing " $i
	OBSERVATORY=`echo $i | cut -d $DELIM -f2`
	OBSERVATORY=`echo "$OBSERVATORY" | cut -d "." -f1`
	
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f1`
	YEAR=`echo "$TIMESTAMP" | cut -c 1-4`
	MONTH=`echo "$TIMESTAMP" | cut -c 5-6`
	DAY=`echo "$TIMESTAMP" | cut -c 7-8`
	HOUR=`echo "$TIMESTAMP" | cut -c 9-10`
	
    # observatory / year / month / day / hour
	DAYDIR="$YEAR$SLASH$MONTH$SLASH$DAY"
	
    # create directory with observatory name, year, month and day if hasn't existed before
	[[ -d "$DAYDIR" ]] || mkdir -p "$DAYDIR" 
	
    # check if directory really exists (if fs is full it might not be created)
	[[ -d "$DAYDIR" ]] && mv "$i" "$DAYDIR"
    
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > LAST
    echo -n "$YEAR$SLASH$MONTH$SLASH$DAY" > "$1"/LAST
    done
else
    echo "No .""$EXT"" files to sort"
fi


exit 0



