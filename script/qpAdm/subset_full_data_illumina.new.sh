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
    poplist=$2
    out=$3
    
    echo "input: $prefix" > $par
    echo "poplist: $poplist" >> $par
    echo "genotypename: $prefix.geno" >> $par
    echo "snpname: $prefix.snp" >> $par
    # echo "indivname: $prefix.ind" >> $par
    echo "indivname: $prefix.ind" >> $par
    echo "outputformat: PACKEDANCESTRYMAP" >> $par
    echo "genotypeoutname: $out.geno" >> $par
    echo "snpoutname: $out.snp" >> $par
    echo "indivoutname: $out.ind" >> $par
    echo "poplistname: $poplist" >> $par

    $convertf -p $par
    rm $par
}


cat ${param_path}/illumina_qpAdm_population.txt > ${param_path}/illumina_qpAdm_population_list.txt 


for i in YR_MN Upper_YR_LN; do
    echo "$i" >> ${param_path}/illumina_qpAdm_population_list.txt
done

convert_file ${file_path}/illumina_all_merged ${param_path}/illumina_qpAdm_population_list.txt  ${file_path}/illumina_all_merged.qpAdm

python group_populations_illumina.py

cp ${file_path}/illumina_all_merged.qpAdm* ${out_path}
