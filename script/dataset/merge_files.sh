#!/bin/sh
module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19

FILE_LIST=$1
OUTPUT=$2
two_pops=${3:-NO}
strandcheck=${4:-YES}


MERGEIT=/home/cliu7/utils/AdmixTools/bin/mergeit
merge_par=$(mktemp merge_par.XXXXXX)

set_snpID_as_position(){
    awk -vOFS=$'\t' '{print $2":"$4,$2,$3,$4,$5,$6}' $1.snp > $1.snp_renamed.snp
}

merge_two_files(){
    FILE1=$1
    FILE2=$2
    OUT=$3

    set_snpID_as_position $FILE1
    set_snpID_as_position $FILE2
    
    echo "geno1: $FILE1.geno" > $merge_par
    echo "snp1: ${FILE1}.snp_renamed.snp" >> $merge_par
    echo "ind1: $FILE1.ind" >> $merge_par
    echo "geno2: $FILE2.geno" >> $merge_par
    echo "snp2: ${FILE2}.snp_renamed.snp" >> $merge_par
    echo "ind2: $FILE2.ind" >> $merge_par
    echo "genooutfilename: $OUT.geno" >> $merge_par
    echo "snpoutfilename: $OUT.snp" >> $merge_par
    echo "indoutfilename: $OUT.ind" >> $merge_par
    if [ $strandcheck = "YES" ]; then
	echo "strandcheck: YES" >> $merge_par
    fi
    echo "allowdups: YES" >> $merge_par
    echo "docheck: YES" >> $merge_par
    echo "hashcheck: NO" >> $merge_par
    $MERGEIT -p $merge_par

    rm ${FILE1}.snp_renamed.snp ${FILE2}.snp_renamed.snp
}

if [ $two_pops = "YES" ]; then
    readarray FLIST < ${FILE_LIST}
    merge_two_files ${FLIST[0]} ${FLIST[1]} $OUTPUT
else
    readarray FLIST < ${FILE_LIST}
    merge_two_files ${FLIST[0]} ${FLIST[1]} merged_1

    let M=${#FLIST[@]}-1
    for ((i=2; i<$M; ++i))
    do
	let p=$i-1
	merge_two_files merged_$p ${FLIST[$i]} merged_$i
    done

    let p=$M-1
    merge_two_files merged_$p ${FLIST[$M]} $OUTPUT

    # clean-up
    for ((i=1; i<$M; ++i))
    do
	rm merged_$i.*
    done
    rm $merge_par
fi
