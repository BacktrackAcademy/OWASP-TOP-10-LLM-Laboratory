#!/usr/bin/env bash
# Diagnóstico rápido del entorno.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
D="$ROOT/dvla"
chk() { if eval "$2" >/dev/null 2>&1; then printf '\033[32m[OK]\033[0m %s\n' "$1"; else printf '\033[31m[X]\033[0m  %s  ->  %s\n' "$1" "$3"; fi; }
chk "Repo DVLA presente"        "[ -f '$D/main.py' ]"                          "ejecuta ./scripts/setup.sh"
chk "Entorno virtual"           "[ -x '$D/env/bin/python' ]"                   "ejecuta ./scripts/setup.sh"
chk "Dependencias (streamlit, litellm)" "'$D/env/bin/python' -c 'import streamlit, langchain_litellm, dotenv'" "reinstala: dvla/env/bin/pip install -r dvla/requirements.txt python-dotenv"
chk ".env configurado"          "grep -q model_name '$D/.env'"                 "cp dvla/.env.ollama.template dvla/.env"
chk "Ollama instalado"          "command -v ollama"                            "https://ollama.com/download"
chk "Ollama responde (:11434)"  "curl -fs http://localhost:11434/api/tags"     "abre la app de Ollama o: ollama serve"
chk "Modelo mistral-nemo"       "ollama list | grep -q mistral-nemo"           "ollama pull mistral-nemo"
chk "App en :8501 (si la arrancaste)" "curl -fs http://localhost:8501/_stcore/health" "ejecuta ./scripts/run.sh en otra terminal"
