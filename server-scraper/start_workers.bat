@echo off
setlocal

rem Check if scraper.exe exists
if not exist "server-scraper.exe" (
    echo Error: server-scraper.exe not found in current directory!
    echo Please build it first: go build -o ../avdb-build/server-scraper.exe ./cmd
    pause
    exit /b
)

echo Starting 5 Scraper Workers...

for /L %%i in (1,1,5) do (
    echo Starting Worker %%i...
    set WORKER_ID=%COMPUTERNAME%@%%i
    start /b server-scraper.exe
    timeout /t 1 >nul
)

echo All 5 workers started.
endlocal
