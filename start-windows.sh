#!/usr/bin/env bash
# Liga o Windows (imagem dockurr/windows) no Codespace. Fica na RAIZ do repositório, junto de install.bat, setup.ps1 e wallpaper.jpg.
SRC="$(cd "$(dirname "$0")" && pwd)"
D="$HOME/nimbus"; mkdir -p "$D/oem" "$D/storage"
cp -f "$SRC/install.bat" "$SRC/setup.ps1" "$SRC/wallpaper.jpg" "$D/oem/" || echo "Aviso: faltam arquivos do repositório"

TOTAL=$(free -g | awk '/Mem:/ {print $2}')
RAM=$(( TOTAL > 5 ? TOTAL - 3 : 2 ))
CORES=$(nproc)
FREE=$(df -BG --output=avail "$D" | tail -1 | tr -dc '0-9')
DISK=$(( FREE > 50 ? 40 : FREE - 10 ))
KVM_OPT=""; [ -e /dev/kvm ] || KVM_OPT="-e KVM=N"
docker rm -f windows >/dev/null 2>&1 || true
docker run -d --name windows --restart unless-stopped --stop-timeout 120 \
  -p 8006:8006 --device=/dev/kvm --device=/dev/net/tun --cap-add NET_ADMIN $KVM_OPT \
  -e VERSION=10 -e LANGUAGE=Portuguese -e USERNAME=nimbus -e PASSWORD=nimbus \
  -e RAM_SIZE="${RAM}G" -e CPU_CORES="$CORES" -e DISK_SIZE="${DISK}G" \
  -v "$D/storage:/storage" -v "$D/oem:/oem" \
  dockurr/windows
echo "Windows iniciando: RAM ${RAM}G, ${CORES} núcleos, disco ${DISK}G."

# Porta 8006 pública (o visitante não é o dono da conta). Precisa do segredo GH_TOKEN nos Codespaces do repositório.
if [ -n "$GH_TOKEN" ] && [ -n "$CODESPACE_NAME" ]; then
  nohup bash -c 'for i in $(seq 1 60); do gh codespace ports visibility 8006:public -c "$CODESPACE_NAME" && break; sleep 5; done' >/dev/null 2>&1 &
fi
