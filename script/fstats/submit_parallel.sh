#!/bin/sh

for i in {1..1854..150}; do
    c=$((i+149))
    qsub HO_f4_worldwide.pbs -F"$i $c"
    sleep 1
    echo "$i $c"
done
