import pandas as pd
import numpy as np
import os
import argparse
import sys
import allel

# parse argument
parser = argparse.ArgumentParser()
parser.add_argument("--chr", help="Chromosome (int)", type=int)
args = parser.parse_args()
chr = args.chr

# read modern allele counts from the reference panel
ancient_groups = ['aACA_merged', 'Chokhopani', 'Rhirhi', 'Kyang', 'Samdzong', 'Mebrak']
modern_pops = ['CHB','TIB']
pops = ancient_groups + modern_pops

acs = {}
for p in modern_pops:
    df = pd.read_table(f"../output/allele_count/{p}.chr{chr}.c1b.txt.gz",
                       compression = 'gzip', 
                       names = ['chr','pos','ref','alt','nref','nalt'],
                       usecols=['nref','nalt'], sep = ' ')
    acs[p] = allel.AlleleCountsArray(df.values.astype(int))
    
for p in ancient_groups:
    df = pd.read_table(f"../output/allele_count/aACA.chr{chr}.{p}.c1b.txt.gz",
                       compression = 'gzip', 
                       names = ['chr','pos','ref','alt','nref','nalt'],
                       usecols=['nref','nalt'], sep = ' ')
    acs[p] = allel.AlleleCountsArray(df.values.astype(int))

    
pos = pd.read_table(f"../output/allele_count/aACA.chr{chr}.{p}.c1b.txt.gz",
                     compression = 'gzip', 
                     names = ['chr','pos','ref','alt','nref','nalt'],
                     usecols=['pos'], sep = ' ').pos.values

#### defining step-wise fstat functions ####
def step_f3(acc, aca, acb, pos, window_size, step, n_thresh = 50):
    '''
    F3(C; A, B) in moving windows in physical distance
    '''
    f3 = []
    win_start = []
    n = []
    T, B = allel.patterson_f3(acc,aca,acb)
    crit = (acc + aca + acb).min(axis = 1) > 0
    T = T[crit]
    pos = pos[crit]
    start = pos[0]
    while start < pos[-1]:
        idx = np.where((pos >= start) & (pos < start + window_size))[0]
        nsnp = crit[idx].sum()
        if nsnp > n_thresh:
            f3.append(np.nanmean(T[idx]))
            win_start.append(start)
            n.append(nsnp)
        else:
            f3.append(float('NaN'))
            win_start.append(start)
            n.append(nsnp)
        start += step
    win_start = [int(s) for s in win_start]
    return f3, win_start, n


def concat_fstat_tables(fstat_dict, f_col):
    pops = list(fstat_dict.keys())
    p = pops[0]
    df = fstat_dict[p][['chrom', 'start_pos']]
    for p in pops:
        df[p] = fstat_dict[p][f_col]
    ord = ['chrom', 'start_pos']
    ord.extend(pops)
    return df[ord]


### compute f-stat and write to cluster
# f3(TIB; CHB, aACA)
w_size = 5e5
s_size = 1e4
f3_collection = {}

for pop in ancient_groups:
    f3s, starts, ns = step_f3(acs['TIB'], acs['CHB'], acs[pop], pos = pos, window_size = w_size, step = s_size)
    f3_collection[pop] = pd.DataFrame({'chrom': list(np.repeat(chr, len(f3s))), 'f3': f3s, 'start_pos': starts})

df = concat_fstat_tables(f3_collection, 'f3')
df.to_csv(f"../output/window_fstats/TIB_CHB_aACA.chr{str(chr)}.window_f3.txt.gz", 
          sep='\t', header=True, index=False, 
          compression = 'gzip', na_rep = 'NA', float_format='%.7f')

