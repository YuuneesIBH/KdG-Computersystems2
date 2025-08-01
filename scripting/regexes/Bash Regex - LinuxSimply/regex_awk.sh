#!/bin/bash

# Extract lines where the second column contains the number "20" from data.txt
awk '$2 ~ /20/ {print}' data.txt
