#!/bin/bash

string="hello"
pattern="[a-z]+"

echo "The string: $string"
echo 
if [[ $string =~ $pattern ]]; then
echo "String matches the regex pattern"
else
echo "String does not match the regex pattern"
fi
