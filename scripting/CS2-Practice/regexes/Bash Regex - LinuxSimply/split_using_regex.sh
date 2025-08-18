#!/bin/bash
text="apple,banana,orange,grape"
delimiter=","
#print the string
echo "The text:"
echo $text
echo
echo "The text after splitting"
# Splitting the text using grep and regex
echo "$text" | grep -oE "[^$delimiter]+"
