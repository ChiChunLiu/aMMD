#!/bin/bash

module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19


convertf='/home/cliu7/utils/AdmixTools/bin/convertf'
file_path='/scratch/cliu7/ancient_ACA/data/tidy/eigenstrat'
out_path='/home/cliu7/ancient_ACA/data/intermediate'
param_path="/home/cliu7/ancient_ACA/data/params/qpAdm"

convert_file () {
    par=$(mktemp merge_par.XXXXXX)

    prefix=$1
    out=$1.qpAdm
    poplist=$2
    
    echo "input: $prefix" > $par
    echo "poplist: $poplist" >> $par
    echo "genotypename: $prefix.geno" >> $par
    echo "snpname: $prefix.snp" >> $par
    echo "indivname: $prefix.ind" >> $par
    echo "outputformat: PACKEDANCESTRYMAP" >> $par
    echo "genotypeoutname: $out.geno" >> $par
    echo "snpoutname: $out.snp" >> $par
    echo "indivoutname: $out.ind" >> $par
    echo "poplistname: $poplist" >> $par

    $convertf -p $par
    rm $par
}

convert_file ${file_path}/HO_all_merged ${param_path}/aACA_qpAdm_population.txt

sed -e 's/Nagaseema/Naga/g' ${file_path}/HO_all_merged.qpAdm.ind > ${file_path}/HO_all_merged.qpAdm.2.ind
sed -ie 's/Chakehshanega/Naga/g' ${file_path}/HO_all_merged.qpAdm.ind


