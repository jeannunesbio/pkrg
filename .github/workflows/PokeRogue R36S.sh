#!/bin/bash
# SPDX-License-Identifier: AGPL-3.0-only
# PokeRogue R36S experimental - launcher; requires upstream pokerogue-rt build.
set -u
HERE="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)"
APP="$HERE/pokerogue-r36s"
LOG="$APP/ultimo-launcher.txt"
mkdir -p "$APP/data"
if [ ! -f "$APP/data/config.txt" ]; then
cat > "$APP/data/config.txt" <<'CONF'
# Teste R36S: modo online, teclado interno, audio desativado inicialmente.
online=1
osk=1
fps30=1
audio=0
log=1
CONF
fi
{
  echo "==== PokeRogue R36S experimental ===="
  date -u '+UTC: %F %T' || true
  uname -rm
  if [ ! -x "$APP/pokerogue-rt" ]; then
    echo "ERRO: binario ARM64 nao encontrado no pacote: $APP/pokerogue-rt"
    exit 126
  fi
  if [ ! -f "$APP/js/bootstrap.js" ]; then
    echo "ERRO: arquivos JS do runtime nao encontrados em $APP/js"
    exit 126
  fi
  echo 'Dependencias ausentes (se houver):'
  if command -v ldd >/dev/null 2>&1; then ldd "$APP/pokerogue-rt" | grep -E 'not found' || true; fi
  export SDL_VIDEODRIVER=kmsdrm
  export LD_LIBRARY_PATH="$APP/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  export SDL_GAMECONTROLLER_ALLOW_BACKGROUND_EVENTS=1
  echo 'Iniciando runtime em 640x480; arquivos de usuario permanecem em pokerogue-r36s/data.'
  cd "$APP" || exit 1
  ./pokerogue-rt --js "$APP/js" --data "$APP/data" --size 640x480
  status=$?
  echo "pokerogue-rt terminou com codigo $status"
  exit "$status"
} > "$LOG" 2>&1
