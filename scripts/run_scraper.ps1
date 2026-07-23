#!/usr/bin/env powershell
# ================================================================
# Scraper runner for Windows (PowerShell) - adapted from run_scraper.sh
#
# PowerShell version for Windows Task Scheduler
# ================================================================

# Set error handling
$ErrorActionPreference = "Stop"

$PROJECT_DIR = (Get-Item "$(Get-Location)").Parent.FullName
Set-Location $PROJECT_DIR

# ── Helper function to check virtualenv ────────────────────────────
function Test-VirtualEnv {
    param([string]$Path)
    if (Test-Path "$Path\venv") { return "venv" }
    if (Test-Path "$Path\.venv") { return ".venv" }
    if (Get-Command pipenv -ErrorAction SilentlyContinue) {
        $venvPath = pipenv env --venv
        if ($venvPath) { return $venvPath }
    }
    return $null
}

# ── Requirements check ────────────────────────────────────────────
$requirementsFile = "requirements.txt"
if (Test-Path $requirementsFile) {
    Write-Host "Installing requirements from $requirementsFile..."
    pip install -r $requirementsFile
}

# ── Virtualenv activation ─────────────────────────────────────────
$venvType = Test-VirtualEnv $PROJECT_DIR
if ($venvType) {
    Write-Host "Using virtualenv: $venvType"
    . "$PROJECT_DIR\$venvType\Scripts\Activate.ps1"
}

# ── Run ───────────────────────────────────────────────────────────
$LOG_DIR = "logs"
if (-not (Test-Path $LOG_DIR)) { New-Item -Path $LOG_DIR -ItemType Directory | Out-Null }

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
Write-Host "[$TIMESTAMP] Started scraper run..."

# Run main.py with all sites
$OUTPUT = python main.py --all @args
Write-Host $OUTPUT
$EXIT_CODE = $?

Write-Host "[$TIMESTAMP] Finished scraper run — exit code $EXIT_CODE" | Out-File -Append "$LOG_DIR\cron.log"
exit $EXIT_CODE
