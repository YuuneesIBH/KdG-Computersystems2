#!/bin/bash

name="Watson"

shopt -s nocasematch

if [[ $name =~ ^watson$ ]]; then
echo "The name is Watson (case-insensitive)."
else
echo "The name is not Watson (case-insensitive)."
fi
