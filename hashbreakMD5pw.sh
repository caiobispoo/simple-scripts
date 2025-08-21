#!/bin/bash

# ==============================================================================
#
# Name: hashbreakMD5pw.sh
# Usage: ./hashbreakMD5pw.sh 5f4dcc3b5aa765d61d8327deb882cf99 mysecretsalt /usr/share/wordlists/rockyou.txt
# Description: Break MD5 password hash
# Last Update: 2025-08-21
# Author: 0xC410
#
# ==============================================================================

# --- VALIDAÇÃO DE ARGUMENTOS ---
if [ "$#" -ne 3 ]; then
    echo "Uso: ./hashbreakMD5pw.sh <hash_search> <salt> <wordlist>"
    echo ""
    echo "Exemplo: ./hashbreakMD5pw.sh 5f4dcc3b5aa765d61d8327deb882cf99 mysecretsalt /usr/share/wordlists/rockyou.txt"
    exit 1
fi

HASH_SEARCH=$1
SALT=$2
WORDLIST=$3

YELLOW="\033[1;33m"
BLUE="\033[1;34m"
GREEN="\033[1;32m"
NC="\033[0m"

# --- VALIDAÇÃO DE ARQUIVO ---
if [ ! -f "$WORDLIST" ]; then
    echo -e "${RED}Erro: The file of wordlist '$WORDLIST' not found.${NC}"
    exit 1
fi

count=0
wordlist_len=$(wc -l < "$WORDLIST")
wordlist_len_digits=${#wordlist_len}

echo ""
echo -e "${BLUE}Starting search of hash: ${GREEN}$HASH_SEARCH${NC}"
echo -e "${BLUE}Salt used: ${GREEN}$SALT${NC}"
echo ""

# --- LOOP ---
while IFS= read -r password; do
    count=$(( count + 1 ))

    # Ignora linhas vazias
    if [ -z "$password" ]; then
        continue
    fi

	md5pw=$( openssl passwd -1 -salt "$SALT" "$password" | cut -d"$" -f4 )

    # Exibe o progresso na mesma linha
    # O uso de \r (carriage return) move o cursor para o início da linha
    # O \033[K limpa a linha a partir do cursor
    printf "\r\033[K[%0${wordlist_len_digits}d/%d] Testing: %s" "$count" "$wordlist_len" "$password"

    if [ "$md5pw" == "$HASH_SEARCH" ]; then
        printf "\r\033[K"
        echo -e "${GREEN}>>> Password Finded! <<<${NC}"
        echo -e "${BLUE}Hash:     ${GREEN}$md5pw${NC}"
        echo -e "${BLUE}Password: ${GREEN}$password${NC}"
        exit 0
    fi
done < "$WORDLIST"

printf "\r\033[K"
echo -e "${YELLOW}Password not found in selectec wordlist.${NC}"
exit 1
