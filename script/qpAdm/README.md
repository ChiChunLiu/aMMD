# Running qpAdm

## Outliers

 - exclude HGDP01182, HGDP01187 in Yi as outliers
 - exclude BM21, BM27, BM43 in Qiang_Daofu as outliers

## Outgroups

 - Mbuti, Anatolia_N, Ami, Mixe, Ganj_Dareh_N, Onge, Villabruna, DevilsGate are always included
 - Either aACA as one supergroup (outgroup1) or Sherpa.LC is added into the outgroup (outgroup2)

## Two-way models

 1. Tibeto-Burman = Yellow River + Highland
  - Target: All Tibeto-Burman speakers of interests
  - Source1: YR_MN, Upper_YR_LN
  - Source2(outgroup): aACA(2), UpperMustang.LC(1,2),  Sherpa.LC(1)
  
 2. Peripheral = Yellow River + Southern China
  - Target: Tibeto-Burman speakers not in the Mustang region or TAR
  - Source1: YR_MN, Upper_YR_LN
  - Source2: Han, Southeast China
  - outgroup: try both

 3. Putatively unadmixed Tibetan = lowland + highland
  - Target: Tibetans in Mustang + Tibetans in TAR
  - Source1: Han, Southeast China, Pathan, Mala
  - Source2: Sherpa.LC(1), UpperMustang(1,2), aACA(2)

 4. Sherpa = lowland + highland
  - Target: Sherpa.LC, Sherpa.Wang
  - Source1: Han, Southeast China, Pathan, Mala
  - Source2: UpperMustang(2), aACA(2)
