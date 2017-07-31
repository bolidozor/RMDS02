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
# | meteor_uflu_130128_0010.jpg
# | meteor_uflu_130128_0011.jpg
# | meteor_uflu_130128_1310.jpg
# | meteor_uflu_130129_1112.jpg
# | meteor_uflu_130129_1113.jpg
# | .
# | .
# | .
#
# after:
#
# |
# |- uflu             <- observatory
# |    |- 2013             <- year
# |         |- 01             <- month
# |             |- 28             <- day
# |             |   |- 00             <- hour
# |             |   |   |- meteor_uflu_130128_0010.jpg
# |             |   |   |- meteor_uflu_130128_0011.jpg
# |             |   |
# |             |   |- 13
# |             |       |- meteor_uflu_130128_1310.jpg
# |             |  
# |             |- 29
# |             |   |- 11
# |                     |- meteor_uflu_130129_0012.jpg
# |                     |- meteor_uflu_130129_0012.jpg
# .
# .
# .
#
#
# filename format must be as meteor_uflu_130128_0010.jpg

EXT=jpg
DELIM="_"
SLASH="/"
LAST=""


# turn on debug
set -x

# none or 1 argument allowed
[[ "$#" -ne 1 ]] && echo "Wrong number of arguments ($#)" && exit 1

# directory in which to sort must exists
[[ ! -d "$1" ]] && echo "Directory doesn't exist" && exit 1
cd $1

# if there are no files with $EXT extension in the directory then quit
ls -f *.$EXT > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in *.$EXT; do
	echo "processing " $i
	PREFIX=`echo $i | cut -d $DELIM -f1,2`
	OBSERVATORY=`echo $PREFIX | cut -d $DELIM -f2`
	POSTFIX=`echo $i | cut -d $DELIM -f4`
	
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f3`
	YEAR=20`echo "$TIMESTAMP" | cut -c 1-2`
	MONTH=`echo "$TIMESTAMP" | cut -c 3-4`
	DAY=`echo "$TIMESTAMP" | cut -c 5-6`
	HOUR=`echo "$POSTFIX" | cut -c 1-2`
	
    # observatory / year / month / day / hour
	DAYDIR="$OBSERVATORY$SLASH$YEAR$SLASH$MONTH$SLASH$DAY$SLASH$HOUR"
	
    # create directory with observatory name, year, month and day if hasn't existed before
	[[ -d "$DAYDIR" ]] || mkdir -p "$DAYDIR" 
	
    # check if directory really exists (if fs is full it might not be created)
	[[ -d "$DAYDIR" ]] && mv "$i" "$DAYDIR"
    done
    
    echo -n "$OBSERVATORY$SLASH$YEAR$SLASH$MONTH$SLASH$DAY" > LAST
else
    echo "No image files to sort"
fi

DIR="bolids"

ls -f *.wav > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in bolid_*.wav; do
	echo "processing bolid " $i
	
	PREFIX=`echo $i | cut -d $DELIM -f1,2`
	OBSERVATORY=`echo $PREFIX | cut -d $DELIM -f2`
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f3`
	YEAR=20`echo "$TIMESTAMP" | cut -c 1-2`
	OUTDIR="$OBSERVATORY$SLASH$DIR$SLASH$YEAR"
	
	[[ -d "$OUTDIR" ]] || mkdir -p "$OUTDIR"
	mv $i "$OUTDIR"
    done    
else
    echo "No wav files to sort"
fi

ls -f *.aux > /dev/null 2>&1
if [ "$?" -eq 0 ]; then
    for i in bolid_*.aux; do
	echo "processing bolid metadata " $i
	
	PREFIX=`echo $i | cut -d $DELIM -f1,2`
	OBSERVATORY=`echo $PREFIX | cut -d $DELIM -f2`
	TIMESTAMP=`echo "$i" | cut -d $DELIM -f3`
	YEAR=20`echo "$TIMESTAMP" | cut -c 1-2`
	OUTDIR="$OBSERVATORY$SLASH$DIR$SLASH$YEAR"
	
	[[ -d "$OUTDIR" ]] || mkdir -p "$OUTDIR"
	mv $i "$OUTDIR"
    done
else
    echo "No aux files to sort"
fi

exit 0



