#!/bin/sh
module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19

MODERN=$1
ANCIENT=$2
OUTPUT=$3
MERGEIT=/home/cliu7/utils/AdmixTools/bin/mergeit
MERGE_PAR=$(mktemp MERGE_PAR.XXXXXX)

#set -x

set_snpID_as_position(){
    awk -vOFS=$'\t' '{print $2":"$4,$2,$3,$4,$5,$6}' $1.snp > $1.snp_renamed.snp
}

merge_two_files(){
    FILE1=$1
    FILE2=$2
    OUT=$3

    set_snpID_as_position $FILE1
    set_snpID_as_position $FILE2
    
    echo "geno1: ${FILE1}.geno" > $MERGE_PAR
    echo "snp1: ${FILE1}.snp_renamed.snp" >> $MERGE_PAR
    echo "ind1: ${FILE1}.ind" >> $MERGE_PAR
    echo "geno2: ${FILE2}.geno" >> $MERGE_PAR
    echo "snp2: ${FILE2}.snp_renamed.snp" >> $MERGE_PAR
    echo "ind2: ${FILE2}.ind" >> $MERGE_PAR
    echo "genooutfilename: ${OUT}.geno" >> $MERGE_PAR
    echo "snpoutfilename: ${OUT}.snp" >> $MERGE_PAR
    echo "indoutfilename: ${OUT}.ind" >> $MERGE_PAR
    echo "strandcheck: YES" >> $MERGE_PAR
    echo "allowdups: YES" >> $MERGE_PAR
    echo "docheck: YES" >> $MERGE_PAR
    echo "hashcheck: NO" >> $MERGE_PAR
    $MERGEIT -p $MERGE_PAR

    rm ${FILE1}.snp_renamed.snp ${FILE2}.snp_renamed.snp
}

merge_two_files $MODERN $ANCIENT $OUTPUT
rm $MERGE_PAR 
