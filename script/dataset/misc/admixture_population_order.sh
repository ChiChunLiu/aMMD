#!/bin/sh

scratch_data="/scratch/cliu7/ancient_TBN/data"
poplist="/home/cliu7/ancient_TBN/data/support/params/admixture/HO_admixture_population.txt"
nakatsuka_population="${scratch_data}/support/dataset_info/nakatsuka.population_info.txt"
lazaridis_population="${scratch_data}/support/dataset_info/Lazaridis2014_population_information.csv"

echo "Mbuti French Onge" | tr " " "\n" > $poplist
grep Uttarakhand $nakatsuka_population  | cut -f3 | sort | uniq >> $poplist
grep Uttar_Pradesh  $nakatsuka_population | cut -f3 | sort | uniq >> $poplist
grep CentralAsiaSiberia $lazaridis_population | cut -f1 -d, | sort | uniq >> $poplist
grep EastAsia $lazaridis_population | cut -f1 -d, | sort | uniq >> $poplist
grep TibetoBurmese  $nakatsuka_population | cut -f3 | sort | uniq >> $poplist
echo "Sherpa.LC UpperMustang.LC" | tr " " "\n"  >> $poplist
echo "Chokhopani Rhirhi Lubrak Mebrak Kyang Samdzong DevilsGate Tianyuan" | tr " " "\n" >> $poplist

module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19

CONVERTF='/home/cliu7/utils/AdmixTools/bin/convertf'
ADMIXTURE="/home/cliu7/utils/admixture_linux-1.3.0/admixture"
scratch_data="/scratch/cliu7/ancient_TBN/data"

subset=${1:-NO}

subset_eigenstrat() {
    local par=$(mktemp par.XXXXXX)
    local poplist=$(mktemp poplist.XXXXXX)
    local prefix=$2
    local out=$3
    echo $1 | tr " " "\n"  > ${poplist}
    echo "genotypename: ${prefix}.geno" > $par
    echo "snpname: ${prefix}.snp" >> $par
    echo "indivname: ${prefix}.ind" >> $par
    echo "outputformat: PACKEDANCESTRYMAP" >> $par
    echo "genotypeoutname: ${out}.geno.tmp" >> $par
    echo "snpoutname: ${out}.snp.tmp" >> $par
    echo "indivoutname: ${out}.ind" >> $par
    echo "poplistname: ${poplist}" >> $par
    echo "hashcheck: NO" >> $par

    $CONVERTF -p $par
    rm $par $poplist ${out}.snp.tmp ${out}.geno.tmp 
}

#########################################
## create Human Origin PCA populations ##
#########################################
if [ "$subset" = YES ]; then
    poplist=$(mktemp poplist.XXXXXX)
    nakatsuka_population="${scratch_data}/support/dataset_info/nakatsuka.population_info.txt"
    lazaridis_population="${scratch_data}/support/dataset_info/Lazaridis2014_population_information.csv"

    grep EastAsia $lazaridis_population| cut -f1 -d, | sort | uniq > $poplist
    grep CentralAsiaSiberia $lazaridis_population | cut -f1 -d, | sort | uniq >> $poplist
    grep TibetoBurmese  $nakatsuka_population | cut -f3 | sort | uniq >> $poplist
    grep Uttarakhand $nakatsuka_population  | cut -f3 | sort | uniq >> $poplist
    grep Uttar_Pradesh  $nakatsuka_population | cut -f3 | sort | uniq >> $poplist
    echo "Onge Sherpa.LC UpperMustang.LC" | tr " " "\n"  >> $poplist
    echo "Mbuti French" | tr " " "\n" >> $poplist
    echo "Chokhopani Rhirhi Lubrak Mebrak Kyang Samdzong DevilsGate Tianyuan" | tr " " "\n" >> $poplist
    poplist=$(< $poplist)

    data_final="/scratch/cliu7/ancient_TBN/data/tidy/final"
    data_admixture_subset="/scratch/cliu7/ancient_TBN/data/intermediate/HO_all_merged.20200112.admixture"

    echo "start subsetting..."
    subset_eigenstrat "$poplist" \
                    ${data_final}/HO_all_merged.20200112 \
                    $data_admixture_subset
    
    mv $data_admixture_subset.ind /home/cliu7/ancient_TBN/data/support/params/admixture
fi



