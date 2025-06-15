#!/usr/bin/env bash

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

if [ -z $1 ]; then
        echo -e "${YELLOW}Command: $0 [URLs file]${NC}"
        exit 1
fi

url_file=$1

loop_lines() {
        while IFS= read -r line; do
		url=$(echo $line | cut -d'/' -f3)
		ip=$(host -4 "$url" | grep "has address" | cut -d" " -f4)
		printf "| ${GREEN}%-50s${NC} | ${BLUE}%-15s${NC} |\n" "$line" "$ip"
        done < $url_file
}

echo "+----------------------------------------------------+-----------------+"
printf "| %-50s | %-15s |\n" "HOSTs" "IPs"
echo "+----------------------------------------------------+-----------------+"
loop_lines
echo "+----------------------------------------------------+-----------------+"
