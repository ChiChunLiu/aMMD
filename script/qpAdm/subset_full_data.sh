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


cat ${param_path}/aACA_qpAdm_population.txt > ${param_path}/qpAdm_population_list.txt 

for i in Han_ Qiang_ Tibetan_ ; do
    grep $i ${file_path}/HO_all_merged.ind | awk {'print $3'} | sort | \
	uniq >> ${param_path}/qpAdm_population_list.txt
done

for i in YR_MN Upper_YR_LN Sherpa.Wang Tamang Gurung Maonan Mulam Zhuang Dong_Guizhou Dong_Hunan Li Gelao; do
    echo "$i" >> ${param_path}/qpAdm_population_list.txt
done

echo "Pulliyar" >> ${param_path}/qpAdm_population_list.txt

convert_file ${file_path}/HO_all_merged ${param_path}/qpAdm_population_list.txt

rm -rf ${file_path}/HO_all_merged.qpAdm.grouped.ind
python group_populations.py

cp ${file_path}/HO_all_merged.qpAdm* ${out_path}
