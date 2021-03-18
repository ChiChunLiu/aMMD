#!/bin/sh

CONVERTF='/home/cliu7/utils/AdmixTools/bin/convertf'
PARFILE=$(mktemp convertf_par.XXXXXX)
INPUT_PREFIX=$1
OUTPUT_PREFIX=$2

echo "genotypename: ${INPUT_PREFIX}.bed" > $PARFILE
echo "snpname: ${INPUT_PREFIX}.bim" >> $PARFILE
echo "indivname: ${INPUT_PREFIX}.fam" >> $PARFILE
echo "outputformat: PACKEDANCESTRYMAP" >> $PARFILE
echo "genooutfilename: ${OUTPUT_PREFIX}.geno" >> $PARFILE
echo "snpoutfilename: ${OUTPUT_PREFIX}.snp" >> $PARFILE
echo "indoutfilename: ${OUTPUT_PREFIX}.ind" >> $PARFILE

$CONVERTF -p $PARFILE
rm $PARFILE
