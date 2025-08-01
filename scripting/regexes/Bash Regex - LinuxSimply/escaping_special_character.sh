#!/bin/bash
string='The cost is $100'
pattern='\$100'

if [[ $string =~ $pattern ]]; then
    echo 'Match found'
else
    echo 'Match not found'
fi
