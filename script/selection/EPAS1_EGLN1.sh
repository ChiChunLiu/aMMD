#!/bin/sh

samtools mpileup -f /gpfs/data/novembre-lab/reference_genome/hs37d5.fa -b ../../data/params/selection/aACA_bam_list.txt -BR -q30 -Q30 -l ../../data/params/selection/EGLN1_EPAS1.pos | gzip > ../../output/selection/epas1_egln1.mpileup.txt.gz
