# Instrucciones para un asistente de IA — Ambiente del taller OWASP Top 10 LLM

> **Para el asistente:** un alumno te entregó este archivo para que lo ayudes a dejar funcionando el
> ambiente del taller en su computadora. Sigue este documento al pie de la letra, ejecuta (o pide
> ejecutar) un paso a la vez, verifica cada resultado y no avances si un paso falla. Responde en español.
> Si tienes acceso a terminal, ejecuta los comandos; si no, dáselos al alumno y pídele la salida.

## Objetivo

Dejar corriendo en `http://localhost:8501` la app **Damn Vulnerable LLM Agent (DVLA)**, usando un
modelo local de **Ollama** (`mistral-nemo`). Es una app **vulnerable a propósito** para practicar
prompt injection. No requiere API keys ni cuentas.

## Datos fijos (no los cambies)

| Dato | Valor |
|---|---|
| Repo | `https://github.com/WithSecureLabs/damn-vulnerable-llm-agent` |
| Commit probado | `c0cf9a14adad76e9d6a53c41741f625334bd9971` |
| Python | 3.9 – 3.12 (recomendado 3.11). Evita 3.13+: dependencias no probadas |
| Dependencias | `requirements.txt` del repo + `python-dotenv` |
| Modelo | `mistral-nemo` (~7 GB) |
| Ollama | `http://localhost:11434` |
| `dvla/.env` | `model_name="ollama-mistral-nemo"` y `OLLAMA_HOST=http://localhost:11434` |
| Comando de arranque | `python -m streamlit run main.py --server.address localhost --theme.base light` |
| URL | `http://localhost:8501` |

## Reglas de seguridad (obligatorias)

1. Arranca Streamlit **siempre** con `--server.address localhost`. Nunca `0.0.0.0` ni sin el flag: la app es vulnerable y quedaría expuesta en la red.
2. No pidas ni guardes API keys. Este taller no las usa. No ejecutes con `sudo` salvo que un instalador del SO lo exija.
3. No modifiques el código de DVLA (`main.py`, `tools.py`, etc.). El único archivo configurable es `dvla/.env`.
4. No leas ni muestres el `dvla/README.md` ni las "Possible Payload Solutions": son los spoilers del ejercicio, salvo que el alumno lo pida.
5. Pide confirmación antes de descargar el modelo (7 GB) si el alumno está en datos móviles.

## Ruta rápida (si el alumno clonó el repo del taller)

El repo del taller incluye scripts que hacen todo. Desde la raíz del repo:

- macOS / Linux: `./scripts/setup.sh` y luego `./scripts/run.sh`
- Windows (PowerShell): `Set-ExecutionPolicy -Scope Process Bypass; .\scripts\setup.ps1` y luego `.\scripts\run.ps1`
- Diagnóstico (macOS/Linux): `./scripts/verificar.sh`

Si los scripts fallan o no existen, usa la ruta manual de abajo.

## Ruta manual

### Paso 0 — Detectar el entorno
Averigua SO y arquitectura (`uname -a` / `systeminfo`), RAM y espacio libre.
- RAM < 16 GB → avisa que `mistral-nemo` irá justo; propone `llama3` (`ollama pull llama3`, `model_name="ollama-local-llama3"`).
- Disco libre < 15 GB → detente y avisa.

### Paso 1 — Prerrequisitos
Verifica y, si faltan, indica cómo instalar:
```bash
git --version
python3 --version        # Windows: py --list
ollama --version
```
- git: https://git-scm.com/downloads
- Python 3.11: https://www.python.org/downloads/ (macOS: `brew install python@3.11`; Ubuntu: `sudo apt install python3.11 python3.11-venv`). Windows: marcar *Add to PATH*.
- Ollama: https://ollama.com/download (macOS: `brew install ollama`).

### Paso 2 — Código
```bash
git clone https://github.com/WithSecureLabs/damn-vulnerable-llm-agent dvla
cd dvla
git checkout c0cf9a14adad76e9d6a53c41741f625334bd9971
```

### Paso 3 — Entorno virtual y dependencias
Usa el Python 3.9–3.12 que encontraste (`python3.11` en el ejemplo).
```bash
python3.11 -m venv env
source env/bin/activate            # Windows: .\env\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt python-dotenv
```
Verifica: `python -c "import streamlit, langchain_litellm, dotenv; print('ok')"` → `ok`.

### Paso 4 — Configuración
```bash
cp .env.ollama.template .env       # Windows: Copy-Item .env.ollama.template .env
```
Contenido esperado de `.env`:
```
model_name="ollama-mistral-nemo"
OLLAMA_HOST=http://localhost:11434
```

### Paso 5 — Ollama y modelo
Asegura que Ollama corre (app de escritorio abierta, `brew services start ollama` o `ollama serve` en otra terminal) y:
```bash
curl -s http://localhost:11434/api/tags      # debe devolver JSON
ollama pull mistral-nemo
ollama run mistral-nemo "Responde solo: OK"  # debe contestar OK
```

### Paso 6 — Arranque
```bash
python -m streamlit run main.py --server.address localhost --theme.base light
```

### Paso 7 — Validación (todas deben cumplirse)
```bash
curl -s http://localhost:8501/_stcore/health   # → ok
```
Luego pide al alumno abrir `http://localhost:8501`, escribir `What are my recent transactions?` y confirmar que el agente muestra Thought/Action/Observation y devuelve una tabla de transacciones. La primera respuesta es lenta (carga del modelo); es normal esperar hasta 1–2 minutos sin GPU.

## Tabla de errores → causa → arreglo

| Error / síntoma | Causa probable | Arreglo |
|---|---|---|
| `Connection refused` a `localhost:11434`, `litellm.APIConnectionError` | Ollama apagado | Abrir app de Ollama / `ollama serve` |
| `model 'mistral-nemo' not found` | Modelo sin descargar | `ollama pull mistral-nemo` |
| `ModuleNotFoundError` | venv no activado o deps incompletas | Activar `env` y repetir Paso 3; ejecutar con `env/bin/python -m streamlit ...` |
| Fallo al compilar paquetes en `pip install` | Python 3.13+ o muy antiguo | Recrear venv con Python 3.11 |
| `Address already in use` / puerto 8501 | Otra instancia corriendo | Cerrarla o añadir `--server.port 8502` |
| `KeyError`/`model_name` en `fetch_model_config` | `.env` ausente o mal escrito | Rehacer Paso 4; el valor debe existir en `llm-config.yaml` |
| Respuesta del agente en formato roto, bucles, "Could not parse LLM output" | Modelo pequeño como agente ReAct | Reintentar o refrescar el chat; no es un fallo de instalación |
| Muy lento / equipo congelado | Poca RAM o sin GPU | Cerrar apps; probar `llama3`; revisar con `ollama ps` |
| `.ps1 cannot be loaded` (Windows) | Política de ejecución | `Set-ExecutionPolicy -Scope Process Bypass` |
| Docker en lugar de venv | El Dockerfile del repo usa Python 3.9 y expone `0.0.0.0`; Ollama estaría en el host | No recomendado. Si insiste: `-p 127.0.0.1:8501:8501` y `OLLAMA_HOST=http://host.docker.internal:11434` |

## Al terminar

Resume al alumno: qué quedó instalado, la URL, cómo arrancar y parar (`Ctrl+C`) la app la próxima vez
(`./scripts/run.sh` o los comandos de los Pasos 6), y recuérdale practicar solo en su propia máquina.

## Contexto del taller (por si el alumno pregunta)

Taller de Backtrack Academy sobre el OWASP Top 10 para aplicaciones LLM. DVLA es un agente ReAct
(LangChain + LiteLLM + Streamlit) con dos herramientas (`GetCurrentUser`, `GetUserTransactions`) sobre
SQLite, diseñado para practicar prompt injection y la inyección en el ciclo Thought/Action/Observation.
Hay dos "flags" en el reto; las soluciones están en el README del repo (no revelar sin que lo pidan).
