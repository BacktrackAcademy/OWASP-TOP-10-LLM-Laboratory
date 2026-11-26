#!/usr/bin/env bash
# Prepara el taller en macOS / Linux. Es seguro volver a ejecutarlo.
set -euo pipefail

DVLA_REPO="https://github.com/WithSecureLabs/damn-vulnerable-llm-agent"
DVLA_COMMIT="c0cf9a14adad76e9d6a53c41741f625334bd9971"   # versión probada en el taller
MODELO="mistral-nemo"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DVLA="$ROOT/dvla"

ok()   { printf '\033[32m[OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[!]\033[0m  %s\n' "$*"; }
fail() { printf '\033[31m[X]\033[0m  %s\n' "$*"; exit 1; }

# 1. git
command -v git >/dev/null || fail "Falta git. macOS: xcode-select --install | Linux: sudo apt install git"
ok "git encontrado"

# 2. Python 3.10 - 3.12 (3.9 también funciona; evita 3.13+ por compatibilidad de dependencias)
PY=""
for c in python3.12 python3.11 python3.10 python3.9 python3; do
  if command -v "$c" >/dev/null; then
    v="$("$c" -c 'import sys;print("%d.%d"%sys.version_info[:2])')"
    case "$v" in 3.9|3.10|3.11|3.12) PY="$c"; break;; esac
  fi
done
[ -n "$PY" ] || fail "No encontré Python 3.9–3.12. Instala Python 3.11 (macOS: brew install python@3.11 | Linux: sudo apt install python3.11 python3.11-venv)"
ok "Python: $PY ($($PY --version))"

# 3. Código de DVLA (versión fija)
if [ ! -d "$DVLA/.git" ]; then
  git clone "$DVLA_REPO" "$DVLA"
fi
git -C "$DVLA" fetch --quiet origin 2>/dev/null || true
git -C "$DVLA" checkout --quiet "$DVLA_COMMIT" || warn "No pude fijar la versión; sigo con la actual"
ok "DVLA listo en $DVLA"

# 4. Entorno virtual + dependencias
if [ ! -x "$DVLA/env/bin/python" ]; then
  "$PY" -m venv "$DVLA/env"
fi
"$DVLA/env/bin/python" -m pip install --quiet --upgrade pip
"$DVLA/env/bin/python" -m pip install --quiet -r "$DVLA/requirements.txt" python-dotenv
ok "Dependencias instaladas"

# 5. Configuración (.env) apuntando a Ollama
if [ ! -f "$DVLA/.env" ]; then
  cp "$DVLA/.env.ollama.template" "$DVLA/.env"
  ok ".env creado (modelo ollama-mistral-nemo)"
else
  warn ".env ya existía; no lo toqué"
fi

# 6. Ollama + modelo
if ! command -v ollama >/dev/null; then
  warn "Ollama no está instalado. Instálalo desde https://ollama.com/download (macOS: brew install ollama) y ejecuta de nuevo este script."
  exit 0
fi
ok "Ollama encontrado"
if ! curl -fs http://localhost:11434/api/tags >/dev/null; then
  warn "Ollama no responde. Ábrelo (app de escritorio) o ejecuta: ollama serve   (otra terminal)"
  exit 0
fi
if ollama list | awk 'NR>1{print $1}' | grep -q "^$MODELO"; then
  ok "Modelo $MODELO ya descargado"
else
  echo "Descargando $MODELO (~7 GB, puede tardar)..."
  ollama pull "$MODELO"
  ok "Modelo descargado"
fi

echo
ok "Todo listo. Siguiente paso: ./scripts/run.sh"
