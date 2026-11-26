# Prepara el taller en Windows (PowerShell). Es seguro volver a ejecutarlo.
# Si PowerShell bloquea el script:  Set-ExecutionPolicy -Scope Process Bypass
$ErrorActionPreference = "Stop"
$Repo   = "https://github.com/WithSecureLabs/damn-vulnerable-llm-agent"
$Commit = "c0cf9a14adad76e9d6a53c41741f625334bd9971"
$Modelo = "mistral-nemo"
$Root   = Split-Path -Parent $PSScriptRoot
$Dvla   = Join-Path $Root "dvla"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Falta git: https://git-scm.com/download/win" }

# Python 3.9-3.12 mediante el launcher 'py'
$py = $null
foreach ($v in "3.12","3.11","3.10","3.9") {
  & py "-$v" --version 2>$null | Out-Null
  if ($LASTEXITCODE -eq 0) { $py = @("py","-$v"); break }
}
if (-not $py) { throw "Instala Python 3.11 desde https://www.python.org/downloads/ (marca 'Add to PATH')" }
Write-Host "[OK] Python: $($py -join ' ')"

if (-not (Test-Path (Join-Path $Dvla ".git"))) { git clone $Repo $Dvla }
git -C $Dvla checkout --quiet $Commit
Write-Host "[OK] DVLA en $Dvla"

$venvPy = Join-Path $Dvla "env\Scripts\python.exe"
if (-not (Test-Path $venvPy)) { & $py[0] $py[1] -m venv (Join-Path $Dvla "env") }
& $venvPy -m pip install --quiet --upgrade pip
& $venvPy -m pip install --quiet -r (Join-Path $Dvla "requirements.txt") python-dotenv
Write-Host "[OK] Dependencias instaladas"

$envFile = Join-Path $Dvla ".env"
if (-not (Test-Path $envFile)) { Copy-Item (Join-Path $Dvla ".env.ollama.template") $envFile; Write-Host "[OK] .env creado" }

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
  Write-Host "[!] Instala Ollama: https://ollama.com/download y vuelve a ejecutar este script"; exit 0 }
try { Invoke-WebRequest -UseBasicParsing http://localhost:11434/api/tags | Out-Null }
catch { Write-Host "[!] Ollama no responde. Abre la app de Ollama y reintenta"; exit 0 }
if (-not (ollama list | Select-String "^$Modelo")) { ollama pull $Modelo }
Write-Host "[OK] Todo listo. Siguiente paso: .\scripts\run.ps1"
