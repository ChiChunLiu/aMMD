#!/bin/sh
module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19

CONVERTF=/home/cliu7/utils/AdmixTools/bin/convertf
PAR=$(mktemp merge_par.XXXXXX)

PREFIX=$1
OUT=$2

echo "genotypename: $PREFIX.geno" > $PAR
echo "snpname: $PREFIX.snp" >> $PAR
echo "indivname: $PREFIX.ind" >> $PAR
echo "outputformat: PACKEDPED" >> $PAR
echo "genotypeoutname: $OUT.bed" >> $PAR
echo "snpoutname: $OUT.bim" >> $PAR
echo "indivoutname: $OUT.fam" >> $PAR
echo "familynames: NO" >> $PAR

$CONVERTF -p $PAR
rm $PAR
