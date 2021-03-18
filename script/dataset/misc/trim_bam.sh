#!/bin/bash

TRIM='/home/cliu7/utils/bamUtil_1.0.13/bamUtil/bin/bam trimbam'
FILELIST=$1

while read -r a b; do
    $TRIM "$a" "$b" 5
done < $FILELIST
