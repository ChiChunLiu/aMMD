import os
import itertools

aACA = ["Lubrak", "Rhirhi", "Samdzong", "Mebrak", "Kyang", "Chokhopani"]
yellowRiver = ["Upper_YR_LN"]
highland = aACA + ["Sherpa.LC", "UpperMustang.LC", "Tibetan_Shannan"]
outgroup = ["Mbuti"]

exclude = yellowRiver + highland + outgroup

param_path = "/home/cliu7/ancient_ACA/data/params/fstats"


worldwide_present = []
worldwide_ancient = []

worldwide_ind = "/scratch/cliu7/ancient_ACA/data/raw/eigenstrat/Reich_compilation/v42.4.1240K_HO.anno"
with open(worldwide_ind, 'r') as f:
    for line in f:
        line = line.strip().split('\t')
        if line[6] == 'present':
            worldwide_present.append(line[7])
        else:
            worldwide_ancient.append(line[7])

worldwide_present = list(set(worldwide_present))
worldwide_ancient = list(set(worldwide_ancient))
#print(worldwide_present)
#print(worldwide_ancient)
#print(exclude)
worldwide_present = [w for w in worldwide_present if w not in exclude]
worldwide_ancient = [w for w in worldwide_ancient if w not in exclude]


table1 = f"{param_path}/worldwide_modern_relationship.txt"
try:
    os.remove(table1)
except:
    pass

with open(table1, 'w') as f:
    for w in worldwide_present:
        for h in highland:
            for y in yellowRiver:
                f.write(f"{outgroup[0]} {w} {h} {y}\n")




table1 = f"{param_path}/worldwide_ancient_relationship.txt"
try:
    os.remove(table1)
except:
    pass

with open(table1, 'w') as f:
    for w in worldwide_ancient:
        for h in highland:
            for y in yellowRiver:
                f.write(f"{outgroup[0]} {w} {h} {y}\n")


