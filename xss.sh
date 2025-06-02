#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Reset

# Payloads avançados (cortado para 10, mas você pode adicionar mais)
PAYLOADS=(
  "<script>alert(1)</script>"
  "\"><script>alert(1)</script>"
  "'><img src=x onerror=alert(1)>"
  "\"><svg/onload=alert(1)>"
  "<body onload=alert(1)>"
  "<iframe src=javascript:alert(1)>"
  "<object data=javascript:alert(1)>"
  "<a href=javascript:alert(1)>Clique</a>"
  "<img src=x:alert(1) onerror=eval(src)>"
  "<input onfocus=alert(1) autofocus>"
)

function cabecalho() {
  clear
  echo -e "${CYAN}=============================================="
  echo -e "  🛡️  Scanner de XSS (.js / .html) + Testes reais"
  echo -e "        Profissional - via Termux/Bash"
  echo -e "==============================================${NC}"
}

function pedir_arquivo() {
  echo -ne "${YELLOW}Digite o nome do arquivo .js ou .html: ${NC}"
  read ARQUIVO
  if [[ ! -f "$ARQUIVO" ]]; then
    echo -e "${RED}❌ Arquivo '$ARQUIVO' não encontrado.${NC}"
    return 1
  fi
  return 0
}

function barra_progresso() {
  echo -ne "${BLUE}Progresso: "
  for i in {1..25}; do
    echo -ne "#"
    sleep 0.03
  done
  echo -e "${NC}"
}

function escanear_arquivo() {
  echo -e "\n${GREEN}🔎 Varredura de padrões perigosos em: $ARQUIVO${NC}"
  barra_progresso

  RESULTADO="resultado_${ARQUIVO}.txt"

  grep -Eni 'innerHTML|outerHTML|document.write|insertAdjacentHTML|setAttribute|eval|Function|onerror|srcdoc|location.href|window.name|src="javascript:' "$ARQUIVO" > "$RESULTADO"

  LINHAS=$(wc -l < "$RESULTADO")

  if [[ $LINHAS -eq 0 ]]; then
    echo -e "${YELLOW}Nenhum padrão perigoso encontrado.${NC}"
  else
    echo -e "${GREEN}✅ $LINHAS possíveis vulnerabilidades detectadas."
    echo -e "📁 Detalhes salvos em: ${CYAN}$RESULTADO${NC}"
  fi
}

function testar_payloads_reais() {
  echo -e "\n${GREEN}🚨 Testando payloads XSS diretamente no conteúdo...${NC}"
  for payload in "${PAYLOADS[@]}"; do
    echo -ne "${BLUE}Testando: ${NC}$payload... "
    grep -qF "$payload" "$ARQUIVO" && \
      echo -e "${RED}⚠️ Encontrado!${NC}" || \
      echo -e "${GREEN}Seguro.${NC}"
    sleep 0.1
  done
}

function menu() {
  while true; do
    cabecalho
    if pedir_arquivo; then
      escanear_arquivo
      testar_payloads_reais
    fi
    echo -ne "\n${CYAN}Deseja analisar outro arquivo? (s/n): ${NC}"
    read RESP
    [[ "$RESP" =~ ^[Nn]$ ]] && echo -e "${GREEN}Saindo... 👋${NC}" && break
  done
}

menu
