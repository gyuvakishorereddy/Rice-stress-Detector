# =====================================================
# Rice Stress Detector - Project Launcher (PowerShell)
# =====================================================

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Rice Stress Detector - Starting Application" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Change to script directory
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptPath

# Check if .venv exists
if (-Not (Test-Path ".venv")) {
    Write-Host "[*] Virtual environment not found. Creating .venv..." -ForegroundColor Yellow
    python -m venv .venv
    Write-Host "[+] Virtual environment created" -ForegroundColor Green
    Write-Host ""
}

# Activate virtual environment
Write-Host "[*] Activating virtual environment..." -ForegroundColor Yellow
& .\.venv\Scripts\Activate.ps1

# Install/update dependencies
Write-Host "[*] Installing dependencies..." -ForegroundColor Yellow
pip install -r requirements.txt -q
Write-Host "[+] Dependencies installed" -ForegroundColor Green

# Initialize/check database
Write-Host "[*] Initializing database..." -ForegroundColor Yellow
python init_db.py
Write-Host "[+] Database initialized" -ForegroundColor Green
Write-Host ""

# Create configuration guide
Write-Host "[*] Creating configuration guide..." -ForegroundColor Yellow
$configGuide = @"
==========================================
RICE STRESS DETECTOR - DATABASE CONFIGURATION GUIDE
==========================================

If you need to change the database name or connection settings, 
update the following files:

1. DATABASE CONNECTION (.env file):
   File: .env
   Change: DB_NAME=rice
   To:     DB_NAME=your_new_database_name

2. MAIN DATABASE CONNECTION CLASS:
   File: db_connect.py
   Line: ~24 - self.database = database or os.getenv('DB_NAME', 'rice')
   Change the default from 'rice' to your preferred database name

3. DATABASE INITIALIZATION:
   File: init_db.py
   Line: ~25 - database_name = os.getenv('DB_NAME', 'rice')
   Change the default from 'rice' to your preferred database name

4. SQL SCRIPTS (if using direct SQL):
   Files: 
   - code.sql (Line 3: USE rice;)
   - check_users.sql (Line 5: USE rice;)
   - reset_users.sql (Line 18: USE rice;)
   - view_database.sql (if it exists)

5. TEST/CHECK SCRIPTS:
   File: check_shops.py
   Line: ~7 - database='rice'
   Change to your new database name

MYSQL CONNECTION SETTINGS:
- Host: DB_HOST=127.0.0.1 (change in .env)
- Port: DB_PORT=3306 (change in .env) 
- User: DB_USER=root (change in .env)
- Password: DB_PASSWORD=your_password (change in .env)

STEPS TO CHANGE DATABASE:
1. Update .env file with new database name
2. Restart the application
3. The application will automatically create the new database

For MySQL Workbench:
- Use the same credentials from .env file
- Database name should match DB_NAME in .env

==========================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
==========================================
"@

$configGuide | Out-File -FilePath "DATABASE_CONFIGURATION_GUIDE.txt" -Encoding UTF8
Write-Host "[+] Configuration guide created: DATABASE_CONFIGURATION_GUIDE.txt" -ForegroundColor Green
Write-Host ""

# Start Flask application in background
Write-Host "[+] Starting Flask application..." -ForegroundColor Green
Write-Host "[+] Server will be available at: http://localhost:5000" -ForegroundColor Green
Write-Host ""

# Start Flask app in background job
$job = Start-Job -ScriptBlock {
    Set-Location $args[0]
    & .\.venv\Scripts\python.exe app_auth.py
} -ArgumentList (Get-Location).Path

# Wait a moment for server to start
Write-Host "[*] Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Check if server is running by testing the port
try {
    $connection = Test-NetConnection -ComputerName "localhost" -Port 5000 -WarningAction SilentlyContinue
    if ($connection.TcpTestSucceeded) {
        Write-Host "[+] Server started successfully!" -ForegroundColor Green
        Write-Host "[+] Opening browser..." -ForegroundColor Green
        Start-Process "http://localhost:5000"
    } else {
        Write-Host "[-] Server startup may have failed. Check the output above." -ForegroundColor Red
    }
} catch {
    Write-Host "[-] Could not verify server status. Check manually at http://localhost:5000" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "APPLICATION RUNNING" -ForegroundColor Cyan  
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "URL: http://localhost:5000" -ForegroundColor White
Write-Host "Test Login: test_researcher / test123" -ForegroundColor White
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host "Configuration Guide: DATABASE_CONFIGURATION_GUIDE.txt" -ForegroundColor White
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Wait for the job to complete or user interruption
try {
    Wait-Job $job
} finally {
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue
}
