#!/bin/bash

# URL
url="https://www.example.com/path/to/page?param=value"

# Extract domain using regex
if [[ "$url" =~ ^https?://([^/]+) ]]; then
    domain="${BASH_REMATCH[1]}"
    echo "Domain name: $domain"
else
    echo "Invalid URL"
fi
