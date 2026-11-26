#!/usr/bin/env bash
# Arranca la app vulnerable SOLO en localhost.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/dvla"
[ -x env/bin/python ] || { echo "Primero ejecuta ./scripts/setup.sh"; exit 1; }
echo "Abre http://localhost:8501  (Ctrl+C para parar)"
exec env/bin/python -m streamlit run main.py --server.address localhost --theme.base light
