#!/bin/sh

FILE=$1

commonSNP(){
comm -12 <(sort $1) <(cut --output-delimiter=: -f2,4 $2 | sort)
}

readarray SNPlist < $FILE
n=${#SNPlist[@]}

cut --output-delimiter=: -f2,4 ${SNPlist[1]} > tmp.txt
for i in `seq 2 $n`
do
    commonSNP tmp.txt ${SNPlist[$i]} > tmp.txt
done
