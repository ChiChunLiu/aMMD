#!/bin/python3

import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--prefix", "-p" , help="prefix", type=str)
args = parser.parse_args()

cov_dict = {'2':1, '1': 1, '0':1, '9':0}

inds = []
coverages = []
with open(args.prefix + '.ind', 'r') as ind:
    for line in ind:
        i, _, _ = line.strip().split()
        inds.append(i)
        coverages.append(0)

#print(inds)
#print(coverages)

with open(args.prefix + '.geno', 'r') as geno:
    for line in geno:
        line = list(line.strip())
        #print(line)
        for i, l in enumerate(line):
            coverages[i] += cov_dict[l]


for x in zip(inds, coverages):
    print(x[1])
