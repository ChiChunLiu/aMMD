#!/bin/python


import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input', type = str, default = "", help = "input prefix")
parser.add_argument('-o', '--output', type = str, default = "", help = "output prefix")


args = parser.parse_args()



with open(args.input + '.geno', 'r') as geno:
    with open(args.input + '.snp', 'r') as snp:
        with open(args.output + '.geno', 'w') as geno_out:
            with open(args.output + '.snp', 'w') as snp_out:
                  varp = ''
                  for line1, line2 in zip(geno, snp):
                      var, chrom, cm, pos, a0, a1 = line2.strip().split()
                      if var != varp:
                          geno_out.write(line1)
                          snp_out.write(line2)
                          varp = var
                      else:
                          continue


with open(args.input + '.ind', 'r') as ind:
    with open(args.output + '.ind', 'w') as ind_out:
        for line in ind:
            ind_out.write(line)
