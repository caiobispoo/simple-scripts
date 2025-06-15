#!/usr/bin/env bash

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

# Script Vars
file=$1

if [ -z $1 ]; then
        echo -e "${YELLOW}Command: $0 [file]${NC}"
        exit 1
fi

loop_lines() {
        while IFS= read -r line; do
                printf "| ${GREEN}%-60s${NC} |\n" "$line"
        done < temp.txt
}

grep "href=\"http" "$file" | awk -F'href="' '{print $2}' | cut -d'"' -f1 > temp.txt

echo "+--------------------------------------------------------------+"
printf "| %-60s |\n" "URLs FINDED"
echo "+--------------------------------------------------------------+"
loop_lines
echo "+--------------------------------------------------------------+"

rm temp.txt

