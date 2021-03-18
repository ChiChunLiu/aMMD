file_path = '/scratch/cliu7/ancient_ACA/data/tidy/eigenstrat'
ind_input = f'{file_path}/illumina_all_merged.ind'
ind_output = f'{file_path}/illumina_all_merged.marked.ind'

aACA_related = ['KS8', 'M354', 'R5', 'S18_S20_S21_S22', 'S29_S30']
aACA_badqual = ['C2', 'M240', 'M3490']


with open(ind_input, 'r') as ind_in, open(ind_output, 'w') as ind_out:
    for ind in ind_in:
        sample, sex, population = ind.strip().split()
        if sample in aACA_related:
            population = population + '.related'
            print('found related')
        if sample in aACA_badqual:
            population = population + '.ignore'
        line = f'{sample} {sex} {population}\n'
        ind_out.write(line)

