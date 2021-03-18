#!/bin/sh


make_summary () {

    input_path="/home/cliu7/ancient_ACA/output/qpAdm/$1"
    cd ${input_path}
    result="../$2"
    
    rm -f tmp
    ls *.wave.log > file.list.tmp.txt
    
    sed -i 's/.wave.log//g' file.list.tmp.txt
    
    while read f; do
	grep taildiff $f.wave.log | tail -1 | awk '{print $14}' >> tmp
    done < file.list.tmp.txt

    ls  *.wave.log > tmp2
    sed -i 's/-/ /g' tmp2
    paste -d' ' tmp2 tmp > $result
    
    rm tmp tmp2 file.list.tmp.txt
    sed -i 's/  \+/ /g' $result
    sed -i 's/.wave.log//g' $result

}


make_summary wave qpwave_7outgroups.txt
make_summary wave_outgroup2 qpwave_6outgroups.txt
