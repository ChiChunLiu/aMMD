import os
os.chdir('/scratch/cliu7/ancient_ACA/data/raw/eigenstrat/Nakatsuka2016/UnfilteredData')

param_path = "/home/cliu7/ancient_ACA/data/params/dataset"
indlist = f"{param_path}/nakatsuka_filtered_ind_list.txt"

all_inds = []
with open(indlist, 'r') as f:
    for ind in f:
        all_inds.append(ind.strip())
print(len(all_inds))
        
prefix = "CCMB_All_OriginalIndiaHO_unfiltered_packed"
try:
    os.remove(f'{prefix}.2.ind')
except:
    pass

with open(f'{prefix}.ind', 'r') as f, open(f'{prefix}.2.ind', 'w') as out:
    for line in f:
        ind, sex, pop = line.strip().split()
        if ind not in all_inds:
            out.write(f"{ind} {sex} invalid\n")
        else:
            out.write(f"{ind} {sex} {pop}\n")


