#!/bin/bash
# SPDX-License-Identifier: AGPL-3.0-only
# Tempo de execucao limitado: diagnostico de inicializacao, NAO jogo completo.
set -u
HERE="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)"
APP="$HERE/pokerogue-r36s"
LOG="$HERE/pokerogue-r36s-boot-v3.txt"
mkdir -p "$APP/data"
if [ ! -f "$APP/data/config.txt" ]; then
cat > "$APP/data/config.txt" <<'CONF'
# Configuracao inicial do teste: o teclado embutido evita entrada via PC.
online=1
osk=1
fps30=1
audio=0
log=1
CONF
fi
{
  echo '==== PokeRogue R36S / Teste Boot V3 ===='
  date -u '+Data UTC: %F %T' 2>/dev/null || true
  uname -rm
  echo 'Versao e instalacao:'
  head -c 80 "$APP/UPSTREAM_COMMIT.txt" 2>/dev/null || true
  echo
  if [ ! -x "$APP/pokerogue-rt" ]; then
    echo 'ERRO: pokerogue-rt ausente. Use primeiro o pacote ARM64 gerado pelo GitHub Actions.'
    exit 126
  fi
  if [ ! -f "$APP/js/bootstrap.js" ]; then
    echo 'ERRO: js/bootstrap.js ausente.'
    exit 126
  fi
  export SDL_VIDEODRIVER=kmsdrm
  export LD_LIBRARY_PATH="$APP/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  export SDL_GAMECONTROLLER_ALLOW_BACKGROUND_EVENTS=1
  echo 'Conferindo bibliotecas:'
  if command -v ldd >/dev/null 2>&1; then ldd "$APP/pokerogue-rt" | grep -E 'not found|libfaad|libSDL2|libcurl|libGLES' || true; fi
  echo 'Inicio do runtime (limite de seguranca 180 segundos)...'
  cd "$APP" || exit 1
  if command -v timeout >/dev/null 2>&1; then
    timeout --signal=TERM --kill-after=5s 180s ./pokerogue-rt --js "$APP/js" --data "$APP/data" --size 640x480
    status=$?
  else
    ./pokerogue-rt --js "$APP/js" --data "$APP/data" --size 640x480
    status=$?
  fi
  echo "runtime_exit=$status"
  if [ "$status" -eq 124 ]; then echo 'Observacao: limite de 180 s do teste atingido; nao significa erro do jogo.'; fi
  echo '==== FIM TESTE BOOT ===='
  exit "$status"
} > "$LOG" 2>&1
