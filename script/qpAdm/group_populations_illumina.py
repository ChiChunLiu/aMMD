import os

file_path = '/scratch/cliu7/ancient_ACA/data/tidy/eigenstrat'
ind_input = f'{file_path}/illumina_all_merged.qpAdm.ind'
ind_output2 = f'{file_path}/illumina_all_merged.qpAdm.grouped2.ind'

ancients = ["Chokhopani", "Rhirhi", "Samdzong", "Mebrak", "Lubrak", "Kyang"]

try:
    os.remove(ind_output2)
except:
    pass


with open(ind_input, 'r') as ind_in, open(ind_output2, 'w') as ind_out:
    for ind in ind_in:
        sample, sex, population = ind.strip().split()
        if population in ancients:
            population = "aACA"
        line = f'{sample} {sex} {population}\n'
        ind_out.write(line)
