#!/bin/sh

if [ "$1" = "" ]
then
    echo "Please set your User Object ID , sample: $ idset.sh abcd123456789xyz"
    exit 1
fi
for jsonfilename in `ls *.json`
do
    sed s/\"\"/\"$1\"/g ./${jsonfilename} > ./${jsonfilename}.tmp
    mv ./${jsonfilename}.tmp ./${jsonfilename}
done