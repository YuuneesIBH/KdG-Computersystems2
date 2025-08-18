#!/bin/bash

string="Hello, world!"
#print the string
echo "The string: $string"
echo
if ! [[ "$string" =~ [0-9] ]]; then
echo "String does not contain any digits"
else
echo "String contains at least one digit"
fi
