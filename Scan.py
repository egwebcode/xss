import requests
import urllib.parse
import threading
import queue
import re
import sys

from time import sleep

# === CONFIGURAÇÕES === #
THREADS = 50
TIMEOUT = 5
SHOW_ERRORS = True

# === ENTRADAS === #
target = input("🔗 URL alvo (ex: https://site.com/?xss=): ").strip()

if not target or '=' not in target:
    print("❗ URL inválida. Precisa conter pelo menos um parâmetro com '='.")
    sys.exit(1)

payload_file = input("📂 Nome do arquivo de payloads (ex: payloads.txt): ").strip()

try:
    with open(payload_file, 'r', encoding='utf-8') as f:
        payloads = [line.strip() for line in f if line.strip()]
except FileNotFoundError:
    print("❗ Arquivo de payloads não encontrado.")
    sys.exit(1)

print(f"✅ {len(payloads)} payloads carregados.\n")

# === FILA DE TRABALHO === #
q = queue.Queue()

# Quebra os parâmetros para injeção por nome
def extract_params(url):
    parsed = urllib.parse.urlparse(url)
    params = urllib.parse.parse_qs(parsed.query)
    return list(params.keys())

param_names = extract_params(target)

for param in param_names:
    for payload in payloads:
        q.put((param, payload))

successes = []
failures = []

# === FUNÇÃO DE TESTE === #
def test_injection():
    global successes
    while not q.empty():
        param, payload = q.get()

        parsed = urllib.parse.urlparse(target)
        query = urllib.parse.parse_qs(parsed.query)

        # Injeta payload no parâmetro escolhido
        query[param] = payload
        injected_query = urllib.parse.urlencode(query, doseq=True)
        injected_url = urllib.parse.urlunparse((
            parsed.scheme, parsed.netloc, parsed.path, parsed.params, injected_query, parsed.fragment
        ))

        try:
            r = requests.get(injected_url, timeout=TIMEOUT)
            if payload in r.text:
                print(f"\n✅ VULNERÁVEL → {param}: {payload}\nURL: {injected_url}\n")
                successes.append((param, payload, injected_url))
            else:
                # Mostrar progresso (opcional)
                print(f"🔸 Testando → {param} = {payload[:30]}...", end='\r')
        except Exception as e:
            if SHOW_ERRORS:
                print(f"\n❌ Erro: {e} → {injected_url}\n")
            failures.append((param, payload, str(e)))

        q.task_done()

# === EXECUÇÃO MULTITHREAD === #
threads = []
for _ in range(THREADS):
    t = threading.Thread(target=test_injection)
    t.start()
    threads.append(t)

for t in threads:
    t.join()

# === RELATÓRIO FINAL === #
print("\n==============================")
print("     🔍 RESULTADO FINAL")
print("==============================\n")

if successes:
    for param, payload, url in successes:
        print(f"✅ {param} → {payload}")
        print(f"🔗 {url}\n")
else:
    print("⚠️ Nenhuma vulnerabilidade detectada com os payloads fornecidos.")

if SHOW_ERRORS and failures:
    print("\n❗ Erros encontrados:")
    for param, payload, err in failures:
        print(f"{param} = {payload} → {err}")

print("\n🏁 Teste concluído.\n")
