#!/bin/sh

PREFIX=$1
ANCHOR=$2
ANCHOR_NAME=$3

paste $PREFIX.snp $PREFIX.geno | awk -vOFS=$'\t' '{print $2":"$4,$2,$3,$4,$5,$6,$7}' | uniq |  tee >(cut -f1-6 > $PREFIX.ddup.snp) >(cut -f7 > $PREFIX.ddup.geno)

python /home/cliu7/repo/aDNAtools/fixed2a0a1.py -a $ANCHOR -b $PREFIX.ddup -o $PREFIX.ddup.allele_fixed_${ANCHOR_NAME}

rm $PREFIX.ddup.{snp,geno}
cp $PREFIX.ind $PREFIX.ddup.allele_fixed_${ANCHOR_NAME}.ind
