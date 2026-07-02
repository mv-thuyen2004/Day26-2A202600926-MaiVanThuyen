# start_capstone.ps1
# Native Windows PowerShell script to start A2A specialist servers and ADK Web UI

$ROOT = Resolve-Path "."
$env:PYTHONPATH = "$ROOT"

# 1. Load .env file
if (Test-Path "$ROOT\.env") {
    Get-Content "$ROOT\.env" | ForEach-Object {
        if ($_ -match '^\s*([^#=\s]+)\s*=\s*(.*)$') {
            $name = $Matches[1].Trim()
            $value = $Matches[2].Trim().Trim('"').Trim("'")
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
    Write-Host "-> .env loaded successfully"
} else {
    Write-Warning "No .env file found!"
}

# 2. Paths to python and adk
$PYTHON = "D:\anaconda3\envs\pii-env\python.exe"
$ADK = "D:\anaconda3\envs\pii-env\Scripts\adk.exe"

if (!(Test-Path $PYTHON)) {
    Write-Host "Trying fallback python path..."
    $PYTHON = "python"
}

# 3. Kill existing servers on ports 8001, 8002, 8003
Write-Host "-> Stopping existing A2A servers..."
Get-Process | Where-Object { $_.MainWindowTitle -match "uvicorn" -or $_.ProcessName -match "python" } | ForEach-Object {
    try {
        $nets = Get-NetTCPConnection -LocalPort 8001,8002,8003 -ErrorAction SilentlyContinue
        if ($nets) {
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

# Ensure directories exist
if (!(Test-Path "$ROOT\logs")) {
    New-Item -ItemType Directory -Path "$ROOT\logs" | Out-Null
}

# 4. Start A2A specialists in the background
Write-Host "-> Starting search_agent on port 8001..."
Start-Process -FilePath $PYTHON -ArgumentList "-m uvicorn agents.search_agent.agent:a2a_app --host localhost --port 8001" -NoNewWindow -RedirectStandardOutput "$ROOT\logs\search_agent.log" -RedirectStandardError "$ROOT\logs\search_agent_err.log"

Write-Host "-> Starting database_agent on port 8002..."
Start-Process -FilePath $PYTHON -ArgumentList "-m uvicorn agents.database_agent.agent:a2a_app --host localhost --port 8002" -NoNewWindow -RedirectStandardOutput "$ROOT\logs\database_agent.log" -RedirectStandardError "$ROOT\logs\database_agent_err.log"

Write-Host "-> Starting synthesis_agent on port 8003..."
Start-Process -FilePath $PYTHON -ArgumentList "-m uvicorn agents.synthesis_agent.agent:a2a_app --host localhost --port 8003" -NoNewWindow -RedirectStandardOutput "$ROOT\logs\synthesis_agent.log" -RedirectStandardError "$ROOT\logs\synthesis_agent_err.log"

# Wait for servers to spin up
Write-Host "-> Waiting for servers to initialize..."
Start-Sleep -Seconds 5

# 5. Start ADK Web UI in the foreground
Write-Host "=========================================================="
Write-Host "  Day 26 Capstone - MCP + A2A Multi-Agent"
Write-Host "  URL: http://localhost:8000"
Write-Host "  Press Ctrl+C in this terminal to stop ADK Web UI"
Write-Host "=========================================================="

# Run ADK Web
& $ADK web agents/orchestrator
