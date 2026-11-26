$Root = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $Root "dvla")
Write-Host "Abre http://localhost:8501  (Ctrl+C para parar)"
& .\env\Scripts\python.exe -m streamlit run main.py --server.address localhost --theme.base light
