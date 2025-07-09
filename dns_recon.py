#!/usr/bin/env python3
# Problemas
# =========
# - O script não consegue identificar mais de um ip por domínio,
#   por causa dos balanceadores

import dns.resolver
import time
import os
import argparse


def main():
    RED = "\033[1;31m"
    GREEN = "\033[1;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[1;34m"
    NC = "\033[0m"

    parser = argparse.ArgumentParser(description="Enumerador de Subdomínios DNS")
    parser.add_argument("dominio", help="O domínio alvo para a enumeração.")
    parser.add_argument("-w", "--wordlist", help="Caminho para o arquivo de wordlist.")
    args = parser.parse_args()

    target_domain = args.dominio
    target_domain_name = target_domain.split(".")[0]
    target_ips_output = f"ips_{target_domain_name}.txt"

    script_dir = os.path.dirname(__file__)
    default_wordlist = os.path.join(script_dir, "wordlist.txt")
    wordlist_path = ""
    subdomains = []
    print()

    if args.wordlist:
        wordlist_path = args.wordlist
        print(
            f"[@] Utilzando wordlist fornecida pelo usuário: {YELLOW}{wordlist_path}{NC}"
        )

    elif os.path.exists(default_wordlist):
        wordlist_path = default_wordlist
        print(f"[@] Utilizando wordlist padrão: {YELLOW}{default_wordlist}{NC}")

    if wordlist_path:
        try:
            with open(f"{wordlist_path}", "r") as file:
                subdomains = [line.strip() for line in file]
        except (FileNotFoundError, IOError):
            print(
                f"[!] ERRO: Não foi possível ler o arquivo: '{RED}{wordlist_path}{NC}'"
            )
            exit()

    else:
        print(
            "[!!!] Nenhuma wordlist encontrada. Usando a lista interna do script [!!!]"
        )
        subdomains = ["www", "mail", "ftp", "admin", "api", "dev"]

    if os.path.exists(f"{target_ips_output}"):
        os.remove(f"{target_ips_output}")

    for subd in subdomains:
        target = f"{subd}.{target_domain}"
        print(f"[*] Iniciando enumeração de susdomínios para: {BLUE}{target}{NC}")

        try:
            response = dns.resolver.resolve(target, "A")
            for ip in response:
                ip = ip.to_text()
                print(f"[+] IP encontrado: {GREEN}{ip}{NC}")

            with open(f"{target_ips_output}", "a") as file:
                file.write(f"{ip}\n")

        except dns.resolver.NXDOMAIN:
            print(f"[-] subdomínio '{RED}{target}{NC}' não existe. (NXDOMAIN)")

        except dns.resolver.NoAnswer:
            print(f"[!] O subdimínio '{target}' existe, mas não possui registros 'A'.")

        except Exception as e:
            print(f"[!] Ocorreu um erro inesperado: {e}")

        # print("=" * 70)
        time.sleep(0.5)

    print(f"{'Finalizado':^70}")
    print()


if __name__ == "__main__":
    main()
