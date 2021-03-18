#!/bin/bash
#PBS -N run_qpgraph
#PBS -S /bin/bash
#PBS -l mem=10gb
#PBS -l walltime=08:00:00
#PBS -l nodes=1:ppn=10

module load gcc/6.2.0
module load gsl/2.3
module load openblas/0.2.19
module load parallel/20170122
module load graphviz/2.40.1

##################################
## 1. Generate a template file  ##
##    set up qpgraph function   ## 
##################################
qpGraph="/home/cliu7/utils/AdmixTools/bin/qpGraph"
graphwriter="python2 /home/cliu7/ancient_ACA/script/qpgraph/graph_writer_170718.py"
param_directory="/home/cliu7/ancient_ACA/data/params/qpgraph/HumanOrigin"
data_prefix="HO_all_merged.qpsubset"
data_directory='/home/cliu7/ancient_ACA/data/intermediate'
param_file="${param_directory}/qpgraph_HO.par"

echo "DIR: ${data_directory}" > ${param_file}
echo "genotypename: DIR/${data_prefix}.geno" >> ${param_file}
echo "snpname: DIR/${data_prefix}.snp" >> ${param_file}
echo "indivname: DIR/${data_prefix}.ind" >> ${param_file}
echo -e 'outpop: Mbuti\nblgsize: 0.050\ndiag: .0001\nhires: YES' >> ${param_file}
echo -e 'initmix: 1000\nprecision: .0001\nzthresh: 2.0' >> ${param_file}
echo -e 'terse: NO\nuseallsnps: NO' >> ${param_file}

cd ${param_directory}

# basalEA = Onge or Tianyuan
# create ((basalEA, Loschbour), Mbuti)
basalEA=$1
for b in ${basalEA}
do
	${graphwriter} --pop=Mbuti,Loschbour > Mbuti.Loschbour.graph
	${graphwriter} --in=Mbuti.Loschbour --pop=${b} --at=b_n000_n002
	mv Mbuti.Loschbour.${b}.1.graph Mbuti.Loschbour.${b}.graph
done

run_qpgraphs () {
    param_file="${param_directory}/qpgraph_HO.par"
    groups="$1"
    graph1="$2"
    n="$3"
	basalEA="$4"
	test_root=${5:-NO}
	one_way=${6:-NO}
    graph_list="graph_list_${graph1}.txt"
    
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
		if [ $one_way = "YES" ]; then
			tnum1=($(ls ${graph2}.1way.*.graph | wc -l))
			rm -f $graph_list
			for K in $(seq 1 $tnum1); do echo ${graph2}.1way.${K} >> ${graph_list}; done
		else
			tnum1=($(ls ${graph2}.1way.*.graph | wc -l))
			tnum2=($(ls ${graph2}.2way.*.graph | wc -l))
			rm -f $graph_list
			for K in $(seq 1 $tnum1); do echo ${graph2}.1way.${K} >> ${graph_list}; done
			for K in $(seq 1 $tnum2); do echo ${graph2}.2way.${K} >> ${graph_list}; done
		fi

		

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

make_directories () {
	groups=$1
	basalEA=$2
	n=$3
	for g in ${groups}; do
		for b in ${basalEA}; do
			mkdir -p ${b}_${n}pops_${g}
	done; done 
}

###################################
## 2. Add Ami to the graph       ##
###################################

# cd ${param_directory}
# groups="Ami"

# for b in ${basalEA}
# do
# 	mkdir -p ${b}_3pops_Ami
# 	cd ${b}_3pops_Ami
# 	graph1="Mbuti.Loschbour.${b}"
# 	run_qpgraphs "${groups}" ${graph1} 3 ${b} YES
# 	cd ..
# done

# #####################################
# # 3. Add DevilsGate to the graph   ##
# #####################################
# cd ${param_directory}

# for b in ${basalEA}
# do
# 	cp ${b}_3pops_Ami/Mbuti.Loschbour.${b}.Ami.1way.4.graph \
# 		Mbuti.Loschbour.${b}.Ami.graph
# done

# groups="DevilsGate"
# make_directories "$groups" "$basalEA" 4

# for b in ${basalEA}; do
#     cd ${b}_4pops_DevilsGate
#     graph1="Mbuti.Loschbour.${b}.Ami"
#     run_qpgraphs "${groups}" ${graph1} 4 ${b} NO NO
#     cd ..
# done

##############################
# 4. Add Mixe to the graph  ##
##############################
cd ${param_directory}

for b in ${basalEA}
do
	cp ${b}_4pops_DevilsGate/Mbuti.Loschbour.${b}.Ami.DevilsGate.2way.3.graph\
		Mbuti.Loschbour.${b}.Ami.DevilsGate.graph
done

groups="Mixe"
make_directories "$groups" "$basalEA" 5

for b in ${basalEA}; do
    cd ${b}_5pops_Mixe
    graph1="Mbuti.Loschbour.${b}.Ami.DevilsGate"
    run_qpgraphs "${groups}" ${graph1} 5 ${b} NO NO
    cd ..
done

# #######################################
# ## 5. Add YellowRiver to the graph   ##
# #######################################
# cd ${param_directory}

# for b in ${basalEA}
# do
#         cp ${b}_5pops_Mixe/Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.2way.5.graph \
#                 Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.graph
# done

# groups="YR_MN Upper_YR_LN"
# make_directories "$groups" "$basalEA" 6

# for b in ${basalEA}; do
#     cd ${b}_6pops_YR_MN
#     graph1="Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe"
#     run_qpgraphs "${groups}" ${graph1} 6 ${b} NO NO
#     cd ..
# done

# ##################################
# ## 6. Add Lubrak to the graph   ##
# ##################################
# cd ${param_directory}
# for b in ${basalEA}
# do
#         cp ${b}_6pops_YR_MN/Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.2way.32.graph \
#                 Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.graph
# done

# groups="Lubrak"
# make_directories "$groups" "$basalEA" 7

# for b in ${basalEA}; do
#     cd ${b}_7pops_Lubrak
#     graph1="Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN"
#     run_qpgraphs "${groups}" ${graph1} 7 ${b} NO NO
#     cd ..
# done


# ######################################
# ## 7. Add Chokhopani to the graph   ##
# ######################################
# cd ${param_directory}

# for b in ${basalEA}
# do
# 	cp ${b}_7pops_Lubrak/Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak.2way.41.graph \
# 			Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak.graph
# done

# groups="Chokhopani Sherpa.LC"
# make_directories "$groups" "$basalEA" 8

# for b in ${basalEA}; do
#     cd ${b}_8pops_Chokhopani
#     graph1="Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak"
#     run_qpgraphs "${groups}" ${graph1} 8 ${b} NO NO
#     cd ..
# done

# ##################################
# ## 8. Add Naxi/Yi to the graph  ##
# ##################################

# groups="Naxi Yi"
# make_directories "$groups" "$basalEA" 8

# for b in ${basalEA}; do
#     cd ${b}_8pops_Chokhopani
#     graph1="Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak"
#     run_qpgraphs "${groups}" ${graph1} 8 ${b} NO NO
#     cd ..
# done

# ################################
# ## 9. Add Naga to the graph   ##
# ################################
# cd ${param_directory}

# for b in ${basalEA}
# do
# 	cp ${b}_8pops_Naxi/Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak.Naxi.1way.14.graph \
# 			Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak.Naxi.graph
# done

# groups="Naga"
# make_directories "$groups" "$basalEA" 9

# for b in ${basalEA}; do
#     cd ${b}_9pops_Naga
#     graph1="Mbuti.Loschbour.${b}.Ami.DevilsGate.Mixe.YR_MN.Lubrak.Naxi"
#     run_qpgraphs "${groups}" ${graph1} 9 ${b} NO NO
#     cd ..
# done
