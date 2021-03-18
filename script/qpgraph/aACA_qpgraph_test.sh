#!/bin/bash
module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19
module load parallel/20170122
module load graphviz/2.40.1

##################################
## 2. Generate a template file  ##
##    set up qpgraph function   ## 
##################################
qpGraph="/home/cliu7/utils/AdmixTools/bin/qpGraph"
graphwriter="python2 /home/cliu7/ancient_TBN/script/qpgraph/graph_writer_170718.py"
param_directory="/home/cliu7/ancient_TBN/data/support/params/qpGraph/himalayan_qpgraph_HO"
data_prefix="HO_merged.qpsubset"
data_directory='/home/cliu7/ancient_TBN/data/intermediate'
param_file="${param_directory}/Himalayan_qpgraph_HO.par"
basalEA="$1"

echo "DIR: ${data_directory}" > ${param_file}
echo "genotypename: DIR/${data_prefix}.geno" >> ${param_file}
echo "snpname: DIR/${data_prefix}.snp" >> ${param_file}
echo "indivname: DIR/${data_prefix}.group2.ind" >> ${param_file}
echo -e 'outpop: Mbuti\nblgsize: 0.050\ndiag: .0001\nhires: YES' >> ${param_file}
echo -e 'initmix: 1000\nprecision: .0001\nzthresh: 2.0' >> ${param_file}
echo -e 'terse: NO\nuseallsnps: NO' >> ${param_file}

cd ${param_directory}
${graphwriter} --pop=Mbuti,Sintashta_MLBA > Mbuti.Sintashta_MLBA.graph
${graphwriter} --in=Mbuti.Sintashta_MLBA --pop=${basalEA} --at=b_n000_n002
mv Mbuti.Sintashta_MLBA.${basalEA}.1.graph Mbuti.Sintashta_MLBA.${basalEA}.graph

run_qpgraphs () {
    param_file="${param_directory}/Himalayan_qpgraph_HO.par"
    groups="$1"
    graph1="$2"
    n="$3"
	test_root=${4:-NO}
    graph_list="graph_list_${graph1}_txt"
    
    for g1 in ${groups}
    do
	cd ../${basalEA}_${n}pops_${g1}/
	target=${g1}
	graph2=${graph1}"."${target}

	cp ../${graph1}.graph ${graph1}.graph
    if [ $test_root = "YES" ]; then
        ${graphwriter} --in=${graph1} --pop=${target} --include_root
    else
        ${graphwriter} --in=${graph1} --pop=${target}
    fi
	## Generate a list of all graphs (without .graph suffix)
	tnum1=($(ls ${graph2}.1way.*.graph | wc -l))
	tnum2=($(ls ${graph2}.2way.*.graph | wc -l))
	rm -f $graph_list
	for K in $(seq 1 $tnum1); do echo ${graph2}.1way.${K} >> ${graph_list}; done
	for K in $(seq 1 $tnum2); do echo ${graph2}.2way.${K} >> ${graph_list}; done

	## Write down qpGraph commands line by line
	rm -f ${graph_list}.txt
	while read K;
	do
	    line1="${qpGraph} -p ${param_file} -g ${K}.graph -o ${K}.graph.out -d ${K}.graph.dot | tee ${K}.log"
	    line2="dot -Tps < ${K}.graph.dot > ${K}.graph.ps"
	    line="${line1}; ${line2}"
	    echo "${line}" >> ${graph_list}.txt
	done < ${graph_list}
	parallel -j 15 -a ${graph_list}.txt
    done



    ## Summarize the output (noutliers, worst f-stat)
    for g1 in ${groups}
    do 
	cd ../${basalEA}_${n}pops_${g1}/
	target=${g1}
	graph2=${graph1}"."${target}
	output1=${graph2}".summary.txt"
	rm -f $output1

	echo -e 'Graph\tnZ2\tnZ3\tworst\tworstZ' > ${output1}
	while read K; do
            tw1=($(grep "worst f-stat" ${K}.log | awk '{print $3":"$4":"$5":"$6}'))
            twn1=($(grep "worst f-stat" ${K}.log | awk '{print $11}'))
            tnum1=($(grep -nw "outliers:" ${K}.log | cut -d ':' -f 1)); let tnum1+=2
            tnum2=($(grep -n "worst f-stat" ${K}.log | cut -d ':' -f 1)); let tnum2-=3
            tz2=($(head -${tnum2} ${K}.log | tail -n +${tnum1} | awk '$9 <= -2 || $9 >= 2' | wc -l))
            tz3=($(head -${tnum2} ${K}.log | tail -n +${tnum1} | awk '$9 <= -3 || $9 >= 3' | wc -l))
            echo -e ${K}"\t"${tz2}"\t"${tz3}"\t"${tw1}"\t"${twn1} >> ${output1}
	done < ${graph_list}
    done

}

##############################################################
## Add Ami to the graph of (Mbuti, (Sintashta_MLBA, basalEA))  ##
##############################################################
groups="Ami"
mkdir -p ${basalEA}_3pops_${groups}
cd ${basalEA}_3pops_${groups}
graph1="Mbuti.Sintashta_MLBA.${basalEA}"
run_qpgraphs "${groups}" Mbuti.Sintashta_MLBA.${basalEA} 3 YES


###########################################################
## Add Devils Gate to the graph of (Mbuti, (Sintashta_MLBA, basalEA))  ##
###########################################################
# cd ${param_directory}
# groups="DevilsGate"
# mkdir -p ${basalEA}_4pops_${groups}
# cd ${basalEA}_4pops_${groups}
# graph1="Mbuti.Sintashta_MLBA.${basalEA}.Sintashta"
# run_qpgraphs "${groups}" Mbuti.Sintashta_MLBA.${basalEA}.Sintashta 4

