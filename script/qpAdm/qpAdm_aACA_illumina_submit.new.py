#!/usr/bin/env python3

# Created 2020-04-02 by Chi-Chun
import os
import time
import subprocess
import shutil
import tempfile
import argparse
import numpy as np
import itertools as it

# Change working directory to project directory
os.chdir('/home/cliu7/ancient_ACA')

def qpAdm_mktmp(par_file_folder, leftpops):
    leftpops = '.'.join(leftpops)
    tmp_suffix = next(tempfile._get_candidate_names())
    param_path = '{}/{}_{}.par{}'.format(par_file_folder, "qpAdm", leftpops, tmp_suffix)
    left_path = '{}/{}.{}'.format(par_file_folder, "left", tmp_suffix)
    right_path = '{}/{}.{}'.format(par_file_folder, "right", tmp_suffix)
    
    while any([os.path.isfile(f) for f in [param_path, left_path, right_path]]):
        tmp_suffix = next(tempfile._get_candidate_names())
        param_path = '{}/{}_{}.par{}'.format(par_file_folder, "qpAdm", leftpops, tmp_suffix)
        left_path = '{}/{}.{}'.format(par_file_folder, "left", tmp_suffix)
        right_path =  '{}/{}.{}'.format(par_file_folder, "right", tmp_suffix)

    return param_path, left_path, right_path
    
### Driver script for qpAdm submission
def qpAdm_run(leftpops,
              rightpops,
              output_file,
              output_folder="output/qpAdm/illumina",
              input_file="illumina_all_merged.qpAdm",
              input_folder="data/intermediate", 
              input_ind_suff="",
              par_file_folder="temp/param", 
              qpAdm_script="script/qpAdm/run_qpAdm.pbs",
              all_snps=False,
              output=True):

    param_path, left_path, right_path = qpAdm_mktmp(par_file_folder, leftpops)
    
    # create the param file:
    with open(param_path, 'w') as f:
        f.write("%s\n" % ("DIR: " + input_folder))
        f.write("%s\n" % ("S1: " + input_file))
        indline = "indivname: DIR/S1" + input_ind_suff + ".ind"
        f.write("%s\n" % indline)
        f.write("%s\n" % "snpname: DIR/S1.snp")
        f.write("%s\n" % "genotypename: DIR/S1.geno")
        f.write("%s\n" % ("popleft: " + left_path))
        f.write("%s\n" % ("popright: " + right_path))
        f.write("%s\n" % "details: YES")   
        if all_snps:
            f.write("%s\n" % "allsnps: YES")
    
    ### Write leftpops rightpops:       
    with open(left_path, 'w') as f:
        f.write("\n".join(leftpops))
        
    with open(right_path, 'w') as f:
        f.write("\n".join(rightpops))
      
    ### Run qpAdm
    output_path = '{}/{}'.format(output_folder, output_file)
    os.system('qsub -F "{} {}" {}'.format(param_path, output_path, qpAdm_script))


def make_dir_if_not_exists(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
        
def print_time():
    print('\n')
    now = datetime.datetime.now()
    print(now.strftime("%Y-%m-%d %H:%M:%S"))
    

def submit_batch_jobs(*targets_sources, outgroup, folder = None, all_snps = False, input_ind_suff = ''):
    njob = 0
    for leftpops in it.product(*targets_sources):
        leftpops = list(leftpops)
        n = len(targets_sources)
        # removed .log
        output_file = ('{}-' * (n-1) + '{}').format(*leftpops)
        if folder:
            make_dir_if_not_exists('output/qpAdm/illumina/' + folder)
            output_file = folder + '/' + output_file
        print(output_file)
        qpAdm_run(leftpops, outgroup, output_file, all_snps = all_snps, input_ind_suff = input_ind_suff)
        njob += 1
        if njob > 50:
            time.sleep(8)
        else:
            time.sleep(2)
            print(njob)

            
# grouping relevant populations

targets = []
# with open('data/params/qpAdm/bhutan_populations.txt', 'r') as f:
with open('data/params/qpAdm/Arciero_populations.txt', 'r') as f:
    for l in f:
        targets.append(l.strip())


tibetan_nepal = ['UpperMustang.LC', 'Nubri.LC', 'Tsum.LC']
aACA = ['Kyang', 'Lubrak', 'Rhirhi', 'Samdzong', 'Chokhopani', 'Mebrak']
YR = ['YR_MN', 'Upper_YR_LN']
highlanders = ['Sherpa.LC'] + aACA
SEA = ['Pathan', 'Pulliyar']
SC = ['Dai']

# outgroup population
outgroup = ["MbutiPygmy",
            "Anatolia_N",
            "Ami.SG",
            "Mixe.SG",
            "Ganj_Dareh_N",
            "Onge.DG",
            "Villabruna",
            "DevilsGate"]

outgroup_sherpa = outgroup + ["Sherpa.LC"]
outgroup_aaca = outgroup + ["aACA"]


if __name__== "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--twoway', action='store_true', help = "two-way model of modern Tibetan")
    parser.add_argument('-e', '--threeway', action='store_true', help = "three-way model of modern Tibetan")
    parser.add_argument('-w', '--wave', action='store_true', help = "qpWave")
    args = parser.parse_args()

    # outgroup_combinations = [(outgroup_sherpa, "Sherpa.LC", ''),
    #                              (outgroup_aaca , "aACA", '.grouped2'),
    #                              (outgroup, '', '')]

    outgroup_combinations = [(outgroup_aaca , "aACA", '.grouped2')]

    
    if args.twoway:
        
        for o in outgroup_combinations:
            if o[1] == "aACA":
                exclude = aACA
            else:
                exclude = []
            # targets = Highland + YR
            highlanders_tmp = [h for h in highlanders if h != o[1] if h not in exclude] # rm outgroup from s1
            submit_batch_jobs(targets, highlanders_tmp, YR, outgroup = o[0],
                              folder = f"two-way/TB_YR_highland_{o[1]}", input_ind_suff = o[2])

            # targets = Yellow River + Southern China
            submit_batch_jobs(targets, YR, SC, outgroup = o[0],
                              folder = f'two-way/peripheral_YR_SC_{o[1]}', input_ind_suff = o[2])

            # targets = lowland + highland
            submit_batch_jobs(targets, highlanders_tmp, SC+SEA, outgroup = o[0],
                              folder = f"two-way/TIB_lowland_highland_{o[1]}", input_ind_suff = o[2])


    elif args.threeway:

        for o in outgroup_combinations:
            if o[1] == "aACA":
                exclude = aACA
            else:
                exclude = []

            #targets = targets + ['Tamang', 'Gurung']
            # source1 = ['Naga', 'Naxi', 'Yi', 'YR_MN', 'Upper_YR_LN
            source1 = ['YR_MN', 'Upper_YR_LN']
            source2 = [h for h in highlanders if h != o[1] if h not in targets + exclude]
            source3 = SEA + SC
            submit_batch_jobs(targets, source1, source2, source3, outgroup = o[0],
                              folder = f"three-way/Arciero_{o[1]}", input_ind_suff = o[2])

       
    elif args.wave:
        source1 = ['Upper_YR_LN']
        source2 = highlanders + ['Han', 'Southeast_China']
        submit_batch_jobs(source1, source2, outgroup = outgroup2, folder = 'wave_outgroup2', input_ind_suff = '.grouped')
        
    else:
        raise Exception('please run one of the qpAdm tests')
