#!/bin/bash

module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19


convertf='/home/cliu7/utils/AdmixTools/bin/convertf'
eigenstrat_path='/scratch/cliu7/ancient_TBN/data/raw/eigenstrat'
merge_file_list='/home/cliu7/ancient_TBN/data/support/params/dataset/HO_Reich_haploid_file.txt'

convert_file () {
    par=$(mktemp merge_par.XXXXXX)

    prefix=$1
    out=${prefix}_subset
    poplist=$2
    echo "input: $prefix\n poplist: $poplist\n"
    
    echo "genotypename: $prefix.geno" > $par
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


pop_param=$(mktemp pop_par.XXXXXX)
# echo "Anatolia_Neolithic" > $pop_param
# convert_file  ${eigenstrat_path}/Mathieson2015/full230 $pop_param

# echo "Ganj_Dareh_N" > $pop_param
# convert_file  ${eigenstrat_path}/Narasimhan2019/centralSouthAsia $pop_param

# echo "Natufian" >> $pop_param
# convert_file  ${eigenstrat_path}/NearEast/AncientLazaridis2016 $pop_param

# echo "Villabruna" >> $pop_param
# convert_file  ${eigenstrat_path}/Fu2016/51.2.2M $pop_param
rm $pop_param



echo "${eigenstrat_path}/Mathieson2015/full230_subset" > $merge_file_list
echo "${eigenstrat_path}/Narasimhan2019/centralSouthAsia_subset" >> $merge_file_list
echo "${eigenstrat_path}/NearEast/AncientLazaridis2016_subset" >> $merge_file_list
echo "${eigenstrat_path}/Fu2016/51.2.2M_subset" >> $merge_file_list



bash merge_files.sh $merge_file_list /scratch/cliu7/ancient_TBN/data/intermediate/HO.Reich.selected_ancients
