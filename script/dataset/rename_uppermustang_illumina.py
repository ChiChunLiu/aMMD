import os, argparse

ind_info = '/home/cliu7/ancient_ACA/data/meta/illumina_omni.population_info.txt'


Nubri = []
Tsum = []
LM = []

with open(ind_info, 'r') as f:
    for line in f:
        sample, sex, pop, *_ = line.strip().split('\t')
        if pop == "Tsum":
            Tsum.append(sample)
        elif pop == "Nubri":
            Nubri.append(sample)
        elif pop == "LowerMustang":
            LM.append(sample)

Nubri_LC = [n + '.LC' for n in Nubri]
Tsum_LC = [t + '.LC' for t in Tsum]
LM_LC = [l + '.LC' for l in LM]




if __name__== "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--input', action='store', help = "input")
    args = parser.parse_args()

    ind_input = f'{args.input}.ind'
    ind_output = f'{args.input}.UM_renamed.ind'

    with open(ind_input, 'r') as ind_in, open(ind_output, 'w') as ind_out:
        for ind in ind_in:
            sample, sex, population = ind.strip().split()
            if sample in Nubri:
                population = 'Nubri.WGS'
            elif sample in Tsum:
                population = 'Tsum.WGS'
            elif sample in LM:
                population = 'LowerMustang.WGS'
            elif sample in Nubri_LC:
                population = 'Nubri.LC'
            elif sample in Tsum_LC:
                population = 'Tsum.LC'
            line = f'{sample} {sex} {population}\n'
            ind_out.write(line)
