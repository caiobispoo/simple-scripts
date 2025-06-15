#! /usr/bin/env bash

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m"

if [ "$EUID" -eq 0 ]; then
	echo -e "${YELLOW}Você não deveria utilizar esse comando com privilégios de root.${NC}"
fi

if [ -z "$1" ]; then
	echo -e "${RED}$0 [ip] # ex: 123.456.789"
	exit 1
fi

if [ ! -d ./scan ]; then
	mkdir ./scan
fi

# Script Vars
target=$1
ports=(345 6678 21 5 8888 452 81)
protocol="http"

port_nocking() {
	for port in "${ports[@]}"; do
		status="CLOSE"
		color="$RED"
		if nc -z -w 1 $ip $port &>/dev/null; then
			if wget -q "$protocol://$ip:$port" -O ./scan/webget"${port}"; then
				status="OPEN"
				color="$BLUE"
			else
				status="OK"
				color="$GREEN"
			fi
		fi
		printf "| %-15s | %-8s | ${color}%-8s${NC} |\n" "$ip" "$port" "$status"
		sleep 0.2
	done
}


echo "Iniciando port nocking em: $target"
echo ""
echo "+-----------------+----------+----------+"
printf "| %-15s | %-8s | %-8s |\n" "IP TARGET" "PORT" "STATUS"
echo "+-----------------+----------+----------+"
for i in {0..255}; do
	ip="$target.$i"
	port_nocking
done
echo "+-----------------+----------+----------+"
