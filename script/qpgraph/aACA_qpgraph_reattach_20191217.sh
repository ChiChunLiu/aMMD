#!/bin/bash
#PBS -N run_qpgraph
#PBS -S /bin/bash
#PBS -l mem=15gb
#PBS -l walltime=08:00:00
#PBS -l nodes=1:ppn=10

module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19
module load miniconda3/4.7.10
module load parallel/20170122
module load graphviz/2.40.1

qpGraph="/home/cliu7/utils/AdmixTools/bin/qpGraph"
graphwriter="python /home/cliu7/ancient_TBN/script/qpgraph/reattaching_branch.py"
param_directory="/home/cliu7/ancient_TBN/data/support/params/qpGraph/qpgraph_HO_multiple_basalEA"
data_prefix="HO_merged.qpsubset"
data_directory='/home/cliu7/ancient_TBN/data/intermediate'
param_file="${param_directory}/Himalayan_qpgraph_HO.par"

echo "DIR: ${data_directory}" > ${param_file}
echo "genotypename: DIR/${data_prefix}.geno" >> ${param_file}
echo "snpname: DIR/${data_prefix}.snp" >> ${param_file}
echo "indivname: DIR/${data_prefix}.group2.ind" >> ${param_file}
echo -e 'outpop: Mbuti\nblgsize: 0.050\ndiag: .0001\nhires: YES' >> ${param_file}
echo -e 'initmix: 1000\nprecision: .0001\nzthresh: 2.0' >> ${param_file}
echo -e 'terse: NO\nuseallsnps: NO' >> ${param_file}

run_qpgraphs () {
    param_file="${param_directory}/Himalayan_qpgraph_HO.par"
    m=$1
    a=$2
    b=$3
    graph=$4
    reattached_graph=$5
    graph_list="graph_list_${graph}"

    # Generate reattached graphs
    ${graphwriter} -m $m -a $a -b $b -g $graph -o $reattached_graph

    # Generate a list of all graphs (without .graph suffix)
    tnum=$(($(ls ${reattached_graph}.*.graph | wc -l) - 1))

    rm -f $graph_list
    for K in $(seq 0 $tnum); do echo ${reattached_graph}.${K} >> ${graph_list}; done

    # Write down qpGraph commands line by line
    rm -f ${graph_list}.txt
    while read K;
    do
        line1="${qpGraph} -p ${param_file} -g ${K}.graph -o ${K}.graph.out -d ${K}.graph.dot | tee ${K}.log"
        line2="dot -Tps < ${K}.graph.dot > ${K}.graph.ps"
        line="${line1}; ${line2}"
        echo "${line}" >> ${graph_list}.txt
    done < ${graph_list}
    parallel -j 15 -a ${graph_list}.txt

    # Summarize the output (noutliers, worst f-stat)
	output=${graph}".reattached.summary.txt"
	rm -f $output

	echo -e 'Graph\tnZ2\tnZ3\tworst\tworstZ' > ${output}
	while read K; do
            tw1=($(grep "worst f-stat" ${K}.log | awk '{print $3":"$4":"$5":"$6}'))
            twn1=($(grep "worst f-stat" ${K}.log | awk '{print $11}'))
            tnum1=($(grep -nw "outliers:" ${K}.log | cut -d ':' -f 1)); let tnum1+=2
            tnum2=($(grep -n "worst f-stat" ${K}.log | cut -d ':' -f 1)); let tnum2-=3
            tz2=($(head -${tnum2} ${K}.log | tail -n +${tnum1} | awk '$9 <= -2 || $9 >= 2' | wc -l))
            tz3=($(head -${tnum2} ${K}.log | tail -n +${tnum1} | awk '$9 <= -3 || $9 >= 3' | wc -l))
            echo -e ${K}"\t"${tz2}"\t"${tz3}"\t"${tw1}"\t"${twn1} >> ${output}
	done < ${graph_list} 
}

###################
## run qpgraphs  ##
###################
cd ${param_directory}/EA_source_permutation

basalEA="Hoabinhian Tianyuan"
populations="Naxi Yi"

for basal in $basalEA
do
    for p in $populations
    do  
    g="Mbuti.Loschbour.${basal}.Ami.DevilsGate.Mixe.Lubrak.Chokhopani.Han.${p}.Naga"
    cp "../${basal}_10pops_Naga/${g}.2way.363.graph" "${g}.graph"
done; done


for basal in $basalEA
do
    for pop in $populations
    do
    graph1="Mbuti.Loschbour.${basal}.Ami.DevilsGate.Mixe.Lubrak.Chokhopani.Han.${pop}.Naga"
    run_qpgraphs "n025" "n017" "n026" "${graph1}.graph" "${graph1}.n025_reattached"
done; done
