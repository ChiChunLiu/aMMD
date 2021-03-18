#!/bin/sh
module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19

CONVERTF=/home/cliu7/utils/AdmixTools/bin/convertf
PAR=$(mktemp merge_par.XXXXXX)

PREFIX=$1

echo "genotypename: $PREFIX.packedancestrymapgeno" > $PAR
echo "snpname: $PREFIX.snp" >> $PAR
echo "indivname: $PREFIX.ind" >> $PAR
echo "outputformat: EIGENSTRAT" >> $PAR
echo "genotypeoutname: $PREFIX.geno" >> $PAR
echo "snpoutname: $PREFIX.2.snp" >> $PAR
echo "indivoutname: $PREFIX.2.ind" >> $PAR

$CONVERTF -p $PAR
rm $PAR $PREFIX.2.snp $PREFIX.2.ind

