#!/bin/bash
bestand="cpuinfo.txt"

# maak eerst de txt met systeminfo
lscpu > "$bestand"

# regex loop
while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='NUMA node0 CPU\(s\):[[:space:]]*([0-9-]+)'
    if [[ $lijn =~ $regex ]]; then
        echo "Captured CPUs: ${BASH_REMATCH[1]}"
    fi
done < "$bestand"