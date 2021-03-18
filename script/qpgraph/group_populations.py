file_path = '/scratch/cliu7/ancient_ACA/data/tidy/eigenstrat'
ind_input = f'{file_path}/HO_all_merged.qpgraph.ind'
ind_output = f'{file_path}/HO_all_merged.qpgraph.grouped.ind'
ind_output2 = f'{file_path}/HO_all_merged.qpgraph.grouped2.ind'


core_tibetan = ['Shigatse', 'Shannan','Lhasa', 'Chamdo', 'Nagqu']
core_tibetan = [f'Tibetan_{t}' for t in core_tibetan]
northern_tibetan = [f'Tibetan_{t}' for t in ['Gangcha', 'Xunhua', 'Gannan']]
se_china = ['Maonan', 'Mulam', 'Zhuang', 'Dong_Guizhou', 'Dong_Hunan', 'Li', 'Gelao', 'Dai']


with open(ind_input, 'r') as ind_in, open(ind_output, 'w') as ind_out:
    for ind in ind_in:
        sample, sex, population = ind.strip().split()
        if population in ['Chakehshanega', 'Nagaseema']:
            population = 'Naga'
        elif population in ['Tyumen_HG', 'Sosonivoy_HG']:
            population = 'Botai_N'
        line = f'{sample} {sex} {population}\n'
        ind_out.write(line)

with open(ind_output, 'r') as ind_in, open(ind_output2, 'w') as ind_out:
    for ind in ind_in:
        sample, sex, population = ind.strip().split()
        if 'Botai' in population:
            population = 'Botai'
        line = f'{sample} {sex} {population}\n'
        ind_out.write(line)
