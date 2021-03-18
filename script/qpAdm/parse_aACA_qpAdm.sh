#!/bin/sh


make_summary () {

    input_path="/home/cliu7/ancient_ACA/output/qpAdm/$1"
    cd ${input_path}
    result="../$2"

    ls *.wave.log > file.list.tmp.txt
    sed -i 's/.wave.log//g' file.list.tmp.txt

    rm -rf tmp
    while read f; do
	grep summ $f.log | awk '{$1=$2=$3=""; print}' >> tmp
    done < file.list.tmp.txt


    ls  *.wave.log > tmp2
    sed -i 's/-/ /g' tmp2
    sed -i 's/.wave.log//g' tmp2
    paste -d' ' tmp2 tmp > $result

    
    rm tmp tmp2 file.list.tmp.txt
    sed -i 's/  \+/ /g' $result

}

for DIR in TB_YR_highland TIB_lowland_highland peripheral_YR_SC TMG; do
    for outgroup in aACA Sherpa.LC; do
	make_summary two-way/${DIR}_${outgroup} qpAdm.${DIR}_${outgroup}.result.txt
done; done

for DIR in TB_YR_highland TIB_lowland_highland peripheral_YR_SC TMG; do
    make_summary two-way/${DIR}_ qpAdm.${DIR}.result.txt
done

DIR="TMG"
for outgroup in aACA Sherpa.LC; do
	make_summary three-way/${DIR}_${outgroup} qpAdm.${DIR}_${outgroup}.threeway.result.txt
done
make_summary three-way/${DIR}_ qpAdm.${DIR}.threeway.result.txt


# make_summary continuity continuity/qpAdm.continuity.result.txt
# make_summary three-way three-way/qpAdm.three_way.result.txt

