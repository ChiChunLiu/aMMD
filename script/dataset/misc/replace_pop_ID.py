#!/bin/python3
import argparse

def update_ind(ind, pop):

    pop_map = {}
    with open(pop) as pop_file:
        for line in pop_file:
            s, p = line.strip().split()
            pop_map[s] = p


    with open(ind) as ind_file:
        for line in ind_file:
            s, g, p = line.strip().split()
            if s not in pop_map.keys():
                print('\t'.join([s, g, p]))
            else:
                print('\t'.join([s, g, pop_map[s]]))


if __name__== "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--ind', type = str, default = "", help = "old ind file")
    parser.add_argument('-p', '--population', type = str, default = "", help = "new population label")
    args = parser.parse_args()
    
    update_ind(args.ind, args.population)