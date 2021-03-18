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
              output_folder="output/qpAdm",
              input_file="HO_all_merged.qpsubset",
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
        output_file = ('{}-' * (n-1) + '{}.DR.log').format(*leftpops)
        if folder:
            make_dir_if_not_exists('output/qpAdm/' + folder)
            output_file = folder + '/' + output_file
        print(output_file)
        qpAdm_run(leftpops, outgroup, output_file, all_snps = all_snps, input_ind_suff = input_ind_suff)
        njob += 1
        if njob > 45:
            time.sleep(15)
        else:
            time.sleep(1)
            print(njob)

            

# outgroup population
outgroup = ["Mbuti",
            "Anatolia_N",
            "Ami",
            "Mixe",
            "Ganj_Dareh_N",
            "Onge",
            "Villabruna",
            "DevilsGate"]
outgroup2 = outgroup + ['Sherpa.LC']

# target populations
corridor_tibetan = ['Tibetan_Yunnan', 'Qiang', 'Yi', 'Naxi', 'Tibetan_Xinlong']
ancients = ['Kyang', 'Lubrak', 'Rhirhi', 'Samdzong', 'Chokhopani', 'Mebrak']
highlanders = ['Sherpa.LC'] + ancients
sea = ['Kalash', 'Pathan', 'Brahui', 'Mala']

if __name__== "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--continuity', action='store_true', help = "continuity test")
    parser.add_argument('-t', '--twoway', action='store_true', help = "two-way model of modern Tibetan")
    parser.add_argument('-w', '--threeway', action='store_true', help = "three-way model of modern Tibetan")
    parser.add_argument('-n', '--naga', action='store_true', help = "Naga model")
    parser.add_argument('-s', '--southern_route', action='store_true', help = "comparing Naxi/Yi to Naga")
    parser.add_argument('-r', '--chokhopani_rhirhi', action='store_true', help = "modeling chokhopani and rhirhi")
    args = parser.parse_args()

    if args.continuity:
        targets = ['Sherpa.LC', 'UpperMustang.LC']
        submit_batch_jobs(targets, ancients, outgroup = outgroup, folder = 'continuity', input_ind_suff = '.group2')
        
    elif args.twoway:
        targets = ['UpperMustang.LC', 'Tibetan_core', 'Naga'] + corridor_tibetan
        source2 = ['Southeast_China', 'Han', 'Wuzhuangguoliang']
        submit_batch_jobs(targets, highlanders, source2, outgroup = outgroup, folder = 'two-way', input_ind_suff = '.group2')

#    elif args.threeway:
#        targets = ['Tibetan.WGS', 'UpperMustang.LC', 'Nagaseema', 'Chakehshanega']
#        submit_batch_jobs(targets, highlanders, eas, seas, outgroup = outgroup, folder = 'three-way')

    elif args.naga:
        targets = corridor_tibetan + ['Naga']
        #submit_batch_jobs(targets, highlanders, outgroup = outgroup, folder = 'SA_Tib/one_way_allsnps', input_ind_suff = '_SATib')
        #submit_batch_jobs(targets, highlanders, lowlanders, outgroup = outgroup, folder = 'SA_Tib/two_way_allsnps', input_ind_suff = '_SATib')
        #submit_batch_jobs(targets, eas, seas, outgroup = outgroup, folder = 'SA_Tib/ea_sea_allsnps', input_ind_suff = '_SATib')
        #submit_batch_jobs(targets, highlanders, eas, seas, outgroup = outgroup, folder = 'SA_Tib/three_way_allsnps' ,input_ind_suff = '_SATib')
        #submit_batch_jobs(targets, highlanders, outgroup = outgroup, folder = 'SA_Tib/one_way', input_ind_suff = '_SATib', all_snps = False)
        submit_batch_jobs(targets, highlanders, lowlanders, outgroup = outgroup, folder = 'SA_Tib/two_way', input_ind_suff = '_SATib', all_snps = False)
                          
        #submit_batch_jobs(targets, eas, seas, outgroup = outgroup, folder = 'SA_Tib/ea_sea', input_ind_suff = '_SATib', all_snps = False)
        #submit_batch_jobs(targets, highlanders, eas, seas, outgroup = outgroup, folder = 'SA_Tib/three_way' ,input_ind_suff = '_SATib', all_snps = False)
                          
    elif args.southern_route:
        targets = ['Naxi', 'Yi']
        submit_batch_jobs(targets, eas, ['Naga'], outgroup = outgroup, folder = 'southern_route/naxi_yi_outgroup1', input_ind_suff = '_SATib', all_snps = False)
        submit_batch_jobs(targets, eas, ['Naga'], outgroup = outgroup2, folder = 'southern_route/naxi_yi_outgroup2', input_ind_suff = '_SATib', all_snps = False)
        targets = ['Naga']
        submit_batch_jobs(targets, highlanders, ['Naxi', 'Yi'], outgroup = outgroup, folder = 'southern_route/naga', input_ind_suff = '_SATib', all_snps = False)
    elif args.chokhopani_rhirhi:
        targets = ['Chokhopani', 'Rhirhi']
        highlanders = ['Sherpa.LC', 'Kyang', 'Lubrak']
        lowlanders = eas + seas + ['Naga', 'Naxi', 'Yi']
        submit_batch_jobs(targets, highlanders, lowlanders, outgroup = outgroup, folder = 'chokhopani_rhirhi', input_ind_suff = '_SATib', all_snps = False)
    else:
        raise Exception('please run one of the qpAdm test')
