$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$env:PYTHONUTF8 = '1'
$python = Join-Path $PSScriptRoot 'runtime\venv\Scripts\python.exe'
if (!(Test-Path $python)) {
    if (!(Get-Command py -ErrorAction SilentlyContinue)) {
        throw 'Python 3.11+ with the py launcher is required.'
    }
    py -3 -m venv (Join-Path $PSScriptRoot 'runtime\venv')
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
& $python -c 'import sys; sys.exit(sys.version_info < (3, 11))'
if ($LASTEXITCODE -ne 0) { throw 'Python 3.11+ is required. Recreate runtime\venv with a supported Python.' }
& $python -c "import importlib.util, sys; sys.exit(not all(importlib.util.find_spec(pkg) for pkg in ('frida', 'certifi', 'tzdata')))"
if ($LASTEXITCODE -ne 0) {
    & $python -m pip install --disable-pip-version-check frida==16.7.19 certifi tzdata
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
& $python (Join-Path $PSScriptRoot 'deploy\windows_runtime.py') @args
exit $LASTEXITCODE
