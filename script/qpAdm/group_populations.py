import os

file_path = '/scratch/cliu7/ancient_ACA/data/tidy/eigenstrat'
ind_input = f'{file_path}/HO_all_merged.qpAdm.ind'
ind_output = f'{file_path}/HO_all_merged.qpAdm.grouped.ind'
ind_output2 = f'{file_path}/HO_all_merged.qpAdm.grouped2.ind'


core_tibetan = ['Shigatse', 'Shannan','Lhasa', 'Chamdo', 'Nagqu']
core_tibetan = [f'Tibetan_{t}' for t in core_tibetan] #+ ['Sherpa.Wang']
northern_tibetan = [f'Tibetan_{t}' for t in ['Gangcha', 'Xunhua', 'Gannan']]
se_china = ['Maonan', 'Mulam', 'Zhuang', 'Dong_Guizhou', 'Dong_Hunan', 'Li', 'Gelao', 'Dai']
ancients = ["Chokhopani", "Rhirhi", "Samdzong", "Mebrak", "Lubrak", "Kyang"]
yi_outliers = ["HGDP01187", "HGDP01182"]
qiang_daofu_admixed = ["BM43", "BM27", "BM21"]

try:
    os.remove(ind_output)
    os.remove(ind_output2)
except:
    pass
    
with open(ind_input, 'r') as ind_in, open(ind_output, 'w') as ind_out:
    for ind in ind_in:
        sample, sex, population = ind.strip().split()
        if population in ['Chakehshanega', 'Nagaseema']:
            population = 'Naga'
        # elif population.startswith('Han_'):
        #     population = 'Han'
        # elif population in core_tibetan:
        #     population = 'Tibetan_core'
        # elif population.startswith('Qiang_'):
        #     population  = 'Qiang'
        # elif population in northern_tibetan:
        #     population  = 'Tibetan_northern'
        elif population in se_china:
            population  = 'Southeast_China'
        elif sample in yi_outliers:
            population = population + ".outlier"
        elif sample in qiang_daofu_admixed:
            population = population + ".admixed"
        line = f'{sample} {sex} {population}\n'
        ind_out.write(line)

with open(ind_output, 'r') as ind_in, open(ind_output2, 'w') as ind_out:
    for ind in ind_in:
        sample, sex, population = ind.strip().split()
        if population in ancients:
            population = "aACA"
        line = f'{sample} {sex} {population}\n'
        ind_out.write(line)
