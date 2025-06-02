#!/bin/bash

# Cores para o painel
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem cor

function limpar_tela() {
  clear
}

function cabecalho() {
  echo -e "${CYAN}==========================================="
  echo -e "      Scanner Básico de XSS em arquivos JS"
  echo -e "           Powered by ChatGPT / You"
  echo -e "===========================================${NC}"
}

function pedir_arquivo() {
  echo -ne "${YELLOW}Informe o nome do arquivo .js para escanear: ${NC}"
  read ARQUIVO
  if [[ ! -f "$ARQUIVO" ]]; then
    echo -e "${RED}Arquivo '$ARQUIVO' não encontrado. Tente novamente.${NC}"
    return 1
  fi
  return 0
}

function escanear_arquivo() {
  echo -e "${GREEN}Escaneando o arquivo '$ARQUIVO'...${NC}"
  PATTERNS="innerHTML|document.write|eval|setAttribute|insertAdjacentHTML|outerHTML|onerror"

  grep -En "$PATTERNS" "$ARQUIVO" | tee "resultado_${ARQUIVO}.txt"

  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${YELLOW}Nenhum ponto suspeito encontrado no arquivo.${NC}"
  else
    echo -e "${GREEN}Varredura concluída. Resultados salvos em resultado_${ARQUIVO}.txt${NC}"
  fi
}

function menu() {
  while true; do
    limpar_tela
    cabecalho
    if pedir_arquivo; then
      escanear_arquivo
    fi

    echo -ne "\n${CYAN}Deseja fazer outra análise? (s/n): ${NC}"
    read RESP
    case "$RESP" in
      s|S) continue ;;
      n|N) echo -e "${GREEN}Saindo... Obrigado!${NC}"; break ;;
      *) echo -e "${RED}Resposta inválida. Saindo.${NC}"; break ;;
    esac
  done
}

menu
