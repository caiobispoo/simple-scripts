#! /usr/bin/env bash

###############################################################################
# Funções
# =======

help() {
	echo "Uso: $0 -u <URL> -w <wordlist> [-x <ext1> <ext2> ... ]"
	echo ""
	echo "  -u, --url <URL>            URL do alvo (obrigatório)"
	echo "  -w, --wordlist <WORDLIST>  Caminho para a wordlist (obrigatorio)"
	echo "  -x, --extencions <ext...>  Extenções de arquivos procuradas no recon (opcional)"
	echo "  -h, --help                 Ajuda com relação as opções do script"
	echo ""
	echo "Exemplo: $0 -u alvo.com.br -w /caminho/da/wordlist -e php html txt"
	exit 1
}

###############################################################################
# Variáveis
# =========

URL=""
WORDLIST=""
EXTENCIONS=()
AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0"

###############################################################################
# Verificações
# ============

if [[ "$#" -eq 0 ]]; then
	help
fi

while [[ "$#" -gt 0 ]]; do
	case $1 in
		-u|--url)
			if [[ -n "$2" && ! "$2" =~ ^- ]]; then
				URL=$2
				shift 2
			else
				echo "ERRO: A opção $2 requer um argumento válido." >&2
				help
			fi
			;;

        -w|--wordlist)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                WORDLIST=$2
                shift 2
            else
                echo "ERRO: A opção $2 requer um argumento válido." >&2
                help
            fi
			;;
			
		-x|--extencions)
			shift
			while [[ -n "$1" && ! "$1" =~ ^- ]]; do
				EXTENCIONS+=$1
				shift
			done
			;;
		*)
			echo "ERRO: Opção '$1' desconhecida." >&2
			help
			;;
	esac
done

if [[ -z "$URL" ]]; then
	echo "ERRO: O argumento URL (-u) é obrigatório" >&2
	help
fi

if [[ -z "$WORDLIST" ]]; then
	echo "ERRO: O argumento WORDLIST (-w) é obrigatório" >&2  
	help
fi

if [[ ! -f "$WORDLIST" ]]; then
	echo "ERRO: O arquivo de wordlist não foi encontrado '$WORDLIST'" >&2
	help
fi

#################################################################################
# Script
# ======

tamanho_wordlist=$(wc -l $WORDLIST | cut -d" " -f1)
contador=0

echo ""
echo "Iniciando Recon em: $URL"
echo "Tamanho wordlist: $tamanho_wordlist"
echo "============================================================================================="

while IFS= read -r word; do
	if [[ -z "$word" || "$word" == "" ]]; then
		continue
	fi

	contador=$((contador + 1))
	target_url_dir="$URL/$word/"
	target_url_file="$URL/$word"
	status_base=$(curl -s -o /dev/null -H "User-Agent:$AGENT" -w "%{http_code}" "$target_url_dir")

	printf "\r\033[K[%d/%d] Verificando: %s" "$contador" "$tamanho_wordlist" "$word"

	if [[ "$status_base" != "404" && "$status_base" != "000" ]]; then
		printf "\r\033[K"
		printf "==> Diretório encontrado (status: %s): %s\n" "$status_base" "$target_url_dir"
	fi

	status_base=$(curl -s -o /dev/null -H "User-Agent:$AGENT" -w "%{http_code}" "$target_url_file")

	printf "\r\033[K[%d/%d] Verificando: %s" "$contador" "$tamanho_wordlist" "$word"

	if [[ "$status_base" != "404" && "$status_base" != "000" ]]; then
		printf "\r\033[K"
		printf "[+] Arquivo encontrado (status: %s):   %s\n" "$status_base" "$target_url_file"
	fi

	printf "\r\033[K[%d/%d] Verificando: %s" "$contador" "$tamanho_wordlist" "$word"

	if [[ "${EXTENCIONS[@]}" -gt 0 ]]; then
		printf "\r\033[K"
		for ext in "${EXTENCIONS[@]}"; do
			target_url_ext="$target_url_file.$ext"
			status_base=$(curl -s -o /dev/null -H "User-Agent:$AGENT" -w "%{http_code}" "$target_url_ext")

			if [[ "$status_base" != "404" && "$status_base" != "000" ]]; then
				printf "[+] Arquivo encontrado (status: %s): %s\n" "$status_base" "$target_url_ext"
			fi
		done
	fi
done < "$WORDLIST"
echo "============================================================================================="
echo "Busca finalizada"


















