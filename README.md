# Taller OWASP Top 10 LLM — Instalación para alumnos

Montarás en tu computadora una app de IA **vulnerable a propósito**
([Damn Vulnerable LLM Agent](https://github.com/WithSecureLabs/damn-vulnerable-llm-agent))
con un modelo que corre **localmente** (Ollama). Sin cuentas ni API keys, y nada sale de tu equipo.

> ¿Prefieres que una IA te guíe? Pásale el archivo [`INSTRUCCIONES-PARA-IA.md`](INSTRUCCIONES-PARA-IA.md)
> a ChatGPT, Claude, Gemini, etc. (o ábrelo con Claude Code / Cursor en esta carpeta) y dile:
> *"Ayúdame a dejar listo el ambiente del taller"*.

## Requisitos

| | Mínimo | Recomendado |
|---|---|---|
| RAM | 16 GB | 24 GB o más |
| Disco libre | 15 GB | 20 GB |
| Sistema | macOS, Windows 10/11 o Linux | Apple Silicon o GPU NVIDIA |
| Software | git, Python 3.9–3.12, Ollama | Python 3.11 |

Sin GPU funciona, pero cada respuesta del agente puede tardar de 30 s a varios minutos.
Con poca RAM puedes usar un modelo más pequeño (ver *Problemas frecuentes*), aunque los modelos pequeños fallan más como agentes.

## 1. Instala los programas

- **git**: <https://git-scm.com/downloads>
- **Python 3.11**: <https://www.python.org/downloads/> (en Windows marca *Add python.exe to PATH*)
- **Ollama**: <https://ollama.com/download> (abre la app una vez para que quede corriendo)

## 2. Descarga este repositorio

```bash
git clone https://github.com/BacktrackAcademy/OWASP-TOP-10-LLM-Laboratory.git taller-owasp-llm
cd taller-owasp-llm
```

## 3. Prepara el ambiente (un solo comando)

**macOS / Linux**
```bash
./scripts/setup.sh
```

**Windows (PowerShell)**
```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\setup.ps1
```

El script descarga DVLA en la versión probada, crea el entorno virtual, instala dependencias,
configura `.env` y descarga el modelo `mistral-nemo` (~7 GB, la primera vez tarda).

## 4. Arranca la app

```bash
./scripts/run.sh          # Windows: .\scripts\run.ps1
```

Abre <http://localhost:8501>. Para parar: `Ctrl+C`.

> **Nunca quites `--server.address localhost`.** Sin eso, la app vulnerable queda expuesta a toda tu red (Wi-Fi de la sala, casa, etc.).

## 5. Comprueba que funciona

En el chat escribe: `What are my recent transactions?`

Debes ver al agente razonar (*Thought / Action / Observation*) y devolver una tabla.
La **primera** consulta tarda más porque Ollama carga el modelo en memoria.

Diagnóstico automático (macOS/Linux): `./scripts/verificar.sh`

## Problemas frecuentes

| Síntoma | Solución |
|---|---|
| `Connection refused` / error de litellm | Ollama no está corriendo: abre la app o ejecuta `ollama serve` |
| `model not found` | `ollama pull mistral-nemo` |
| Muy lento o se congela el equipo | Cierra navegadores/apps pesadas; confirma con `ollama ps` que usa GPU |
| Poca RAM (<16 GB) | `ollama pull llama3` y en `dvla/.env` pon `model_name="ollama-local-llama3"` |
| El agente responde cosas sin sentido o error de formato | Normal en modelos chicos: repite la pregunta o reinicia el chat (F5) |
| `pip install` falla | Revisa tu versión de Python (`python --version`); usa 3.9–3.12 |
| Puerto 8501 ocupado | Cierra la otra instancia, o añade `--server.port 8502` al comando de `run` |
| PowerShell bloquea el script | `Set-ExecutionPolicy -Scope Process Bypass` y reintenta |

## Reglas del taller

- Todo se practica **solo en tu propia máquina**. No apliques estas técnicas contra sistemas ajenos sin autorización escrita.
- Sigue la [guía práctica](guia-validacion-owasp-llm.html) (ábrela en el navegador) para probar cada categoría del OWASP Top 10 LLM.
- Evita leer el README de `dvla/` antes de la actividad: contiene las soluciones.

## Estructura

```
taller-owasp-llm/
├── README.md                   <- esta guía
├── guia-validacion-owasp-llm.html  <- guía práctica de ejercicios
├── INSTRUCCIONES-PARA-IA.md    <- guía para que una IA te ayude a instalar
├── scripts/                    <- setup, run y verificar (sh y ps1)
└── dvla/                       <- se crea al ejecutar setup
```
