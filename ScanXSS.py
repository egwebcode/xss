import requests
import threading
import queue
import urllib.parse

# === CONFIGURAÇÃO PRINCIPAL === #
THREADS = 50  # Número de threads simultâneas (ajuste dependendo da máquina)
PAYLOAD_FILE = 'payloads.txt'  # Arquivo com payloads (um por linha)

# === INPUT DO USUÁRIO === #
target = input("Digite a URL alvo (exemplo: https://site.com/page?param=): ").strip()

if not target or "=" not in target:
    print("A URL precisa conter um parâmetro com '=' para injeção.")
    exit()

# === CARREGAR PAYLOADS === #
with open(PAYLOAD_FILE, 'r', encoding='utf-8') as f:
    payloads = [line.strip() for line in f if line.strip()]

print(f"{len(payloads)} payloads carregados.")

q = queue.Queue()
for payload in payloads:
    q.put(payload)

# === FUNÇÃO DE TESTE === #
def test_payload():
    while not q.empty():
        payload = q.get()
        injected_url = target + urllib.parse.quote(payload)
        try:
            r = requests.get(injected_url, timeout=5)
            if payload in r.text:
                print("\n✅ VULNERÁVEL:", injected_url)
                print("   → Payload usado:", payload)
        except:
            pass
        q.task_done()

# === EXECUÇÃO MULTITHREAD === #
threads = []
for _ in range(THREADS):
    t = threading.Thread(target=test_payload)
    t.start()
    threads.append(t)

for t in threads:
    t.join()

print("\n🔎 Testes finalizados.")
