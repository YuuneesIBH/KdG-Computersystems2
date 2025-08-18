#!/bin/bash
string='Regex      in       action'
pattern='Regex in action'

echo "The string: $string"
echo "The regex pattern: $pattern"
echo
if [[ $string =~ $pattern ]]; then
    echo 'Match found'
else
    echo 'Match not found'
fi

echo
echo "Handling whitespace"
new_pattern='Regex\s+in\s+action'
echo "The new regex pattern: $new_pattern"
echo
if [[ $string =~ $new_pattern ]]; then
    echo 'Match found'
else
    echo 'Match not found'
fi

