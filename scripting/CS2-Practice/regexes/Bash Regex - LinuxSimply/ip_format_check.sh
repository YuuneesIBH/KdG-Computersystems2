#!/bin/bash

# IP address
ip="192.168.255.1"
echo "The ip address: $ip"
echo
# Regex pattern for IP address format
regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'

# Check if IP address matches the regex pattern
if [[ $ip =~ $regex ]]; then
    echo "Valid IP address"
else
    echo "Invalid IP address"
fi
