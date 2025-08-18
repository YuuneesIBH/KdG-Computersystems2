#!/bin/bash
# Input string
input="The quick brown fox jumps over the lazy dog."
echo "The input string:"
echo $input
echo

# Perform search and replace using regex
output=$(echo "$input" | sed 's/[aeiou]/#/g')

# Print the modified string
echo "The modified string:"
echo "$output"
