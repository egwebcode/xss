#!/bin/bash

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Reset

function cabecalho() {
  clear
  echo -e "${CYAN}=============================================="
  echo -e "     🔍 Scanner de Vulnerabilidades XSS"
  echo -e "        Profissional - via Termux/Bash"
  echo -e "==============================================${NC}"
}

function pedir_arquivo() {
  echo -ne "${YELLOW}Digite o nome do arquivo .js para analisar: ${NC}"
  read ARQUIVO
  if [[ ! -f "$ARQUIVO" ]]; then
    echo -e "${RED}❌ Arquivo '$ARQUIVO' não encontrado.${NC}"
    return 1
  fi
  return 0
}

function barra_progresso() {
  for i in {1..20}; do
    echo -ne "${BLUE}#"
    sleep 0.05
  done
  echo -e "${NC}"
}

function escanear_arquivo() {
  echo -e "\n${GREEN}🔎 Iniciando varredura em: $ARQUIVO${NC}"
  echo -e "${BLUE}Procurando padrões potencialmente perigosos...${NC}"
  barra_progresso

  RESULTADO="resultado_${ARQUIVO}.txt"

  grep -Eni 'innerHTML|outerHTML|document.write|insertAdjacentHTML|setAttribute|eval|Function|onerror|srcdoc|location.href|window.name' "$ARQUIVO" > "$RESULTADO"

  LINHAS=$(wc -l < "$RESULTADO")

  if [[ $LINHAS -eq 0 ]]; then
    echo -e "${YELLOW}Nenhum padrão perigoso foi detectado.${NC}"
  else
    echo -e "${GREEN}✅ $LINHAS possíveis vulnerabilidades encontradas."
    echo -e "📁 Salvo em: ${CYAN}$RESULTADO${NC}"
  fi
}

function testar_payloads_basicos() {
  echo -e "\n${GREEN}🚨 Testando reações a payloads XSS comuns (simulado)...${NC}"
  echo -e "${BLUE}Simulação de resposta ao conteúdo de payloads populares:${NC}"

  PAYLOADS=(
    "<script>alert(1)</script>"
    "\"><svg/onload=alert(1)>"
    "'><img src=x onerror=alert(1)>"
    "<iframe src='javascript:alert(1)'></iframe>"
  )

  for payload in "${PAYLOADS[@]}"; do
    echo -e "${YELLOW}Testando payload: ${NC}$payload"
    grep -q "$payload" "$ARQUIVO" && \
      echo -e "${RED}⚠️ Encontrado exatamente no arquivo!${NC}" || \
      echo -e "${GREEN}✅ Nenhuma ocorrência exata detectada.${NC}"
    sleep 0.2
  done
}

function menu() {
  while true; do
    cabecalho
    if pedir_arquivo; then
      escanear_arquivo
      testar_payloads_basicos
    fi
    echo -ne "\n${CYAN}Deseja escanear outro arquivo? (s/n): ${NC}"
    read RESP
    [[ "$RESP" =~ ^[Nn]$ ]] && echo -e "${GREEN}Saindo... 👋${NC}" && break
  done
}

menu
