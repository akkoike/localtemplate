#!/bin/sh

for jsonfilename in `ls *.json`
do
    OBJECTID=`grep UserObjectId001 ${jsonfilename} | awk '{ print $2 }'`
    sed s/${OBJECTID}/\"\"/g ${jsonfilename} > ${jsonfilename}.tmp
    mv ${jsonfilename}.tmp ${jsonfilename}
done