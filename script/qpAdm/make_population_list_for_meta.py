tibetan_TAR = ['Shigatse', 'Shannan','Lhasa', 'Chamdo', 'Nagqu']
tibetan_TAR = [f'Tibetan_{t}' for t in tibetan_TAR]
tibetan_northern = [f'Tibetan_{t}' for t in ['Gangcha', 'Xunhua', 'Gannan']]
tibetan_nepal = ['UpperMustang.LC', 'Nubri.LC', 'Tsum.LC', 'Sherpa.LC']
tb_peripheral = ['Tibetan_Yunnan', 'Tibetan_Xinlong', 'Tibetan_Yajiang',
                 'Qiang_Daofu', 'Yi', 'Naxi', 'Naga', 'Tamang', 'Gurung']
aACA = ['Kyang', 'Lubrak', 'Rhirhi', 'Samdzong', 'Chokhopani', 'Mebrak']
YR = ['YR_MN', 'Upper_YR_LN']
SEA = ['Pathan', 'Mala']
SC = ['Han', 'Maonan', 'Mulam', 'Zhuang', 'Dong_Guizhou', 'Dong_Hunan', 'Li', 'Gelao', 'Dai']

outgroup = ["Mbuti",
            "Anatolia_N",
            "Ami",
            "Mixe",
            "Ganj_Dareh_N",
            "Onge",
            "Villabruna",
            "DevilsGate"]


all_pops = tibetan_TAR + tibetan_nepal + tb_peripheral + aACA + YR + SEA + SC + outgroup

with open('../../data/meta/qpAdm_pops.txt', 'w') as f:
    for p in all_pops:
        f.write(p + '\n')
