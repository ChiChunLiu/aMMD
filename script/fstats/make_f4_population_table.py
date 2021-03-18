import os
import itertools

aACA = ["Lubrak", "Rhirhi", "Samdzong",
        "Mebrak", "Kyang", "Chokhopani"]
yellowRiver = ["YR_MN", "Upper_YR_LN"]
highland = ["Sherpa.LC", "UpperMustang.LC", "Tibetan_Lhasa", "Tibetan_Shannan"]
peripheral = ["Naxi", "Yi", "Naga", "Tamang"]
outgroup = "Mbuti"

param_path = "/home/cliu7/ancient_ACA/data/params/fstats"

table1 = f"{param_path}/modern_relationship.txt"
try:
    os.remove(table1)
except:
    pass

with open(table1, 'w') as f:
    # for y, h, a in itertools.product(yellowRiver, highland, aACA):
    #     f.write(f"{outgroup} {y} {h} {a}\n")
    # for p, h, a in itertools.product(peripheral, highland, aACA):
    #     f.write(f"{outgroup} {p} {h} {a}\n")
    # for s, t, a in itertools.product(["Sherpa.LC"], ["UpperMustang.LC"], aACA):
    #     f.write(f"{outgroup} {s} {t} {a}\n")
    # for t, p, y in itertools.product(aACA + highland, peripheral, yellowRiver):
    #     f.write(f"{outgroup} {t} {p} {y}\n")
    for h in highland:
        f.write(f"{outgroup} Mixe {h} Upper_YR_LN\n")      
    f.write(f"{outgroup} DevilsGate Ami YR_MN\n")
    f.write(f"{outgroup} DevilsGate Ami Upper_YR_LN\n")
    for a, h, y in itertools.product(aACA, highland, yellowRiver):
        f.write(f"{outgroup} {a} {h} {y}\n")


table2 = f"{param_path}/ancient_relationship.txt"
try:
    os.remove(
        table2)
except:
    pass        
with open(table2, 'w') as f:
    references = ["Sherpa.LC"] + yellowRiver
    for r, h1, h2 in itertools.product(references, aACA, aACA):
        if h1 != h2:
            f.write(f"{outgroup} {r} {h1} {h2}\n")
    

    
