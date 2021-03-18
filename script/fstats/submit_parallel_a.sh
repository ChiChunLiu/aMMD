#!/bin/sh

for i in {1..15012..150}; do
    c=$((i+149))
    qsub HO_f4_worldwide_a.pbs -F"$i $c"
    sleep 10
    echo "$i $c"
done
