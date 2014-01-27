@echo off

:: Fancy way to enable command extensions, where available
:: http://technet.microsoft.com/en-us/library/bb491001.aspx OR http://www.robvanderwoude.com/allhelpw2ksp4_en.php#SETLOCAL
verify other 2>nul
    setlocal enableextensions
    if errorlevel 1 echo Unable to enable command extensions

for /f "tokens=1 delims= " %%y in ('tasklist /nh /fi "imagename eq winnfsd.exe"') do @set result=%%y

if "%1"=="status" (
    echo "[NFS] Status: "
    if "%result%" == "INFO:" (
        echo "halted"
    ) else (
        echo "running"
    )
)

if "%1"=="start" (
    echo "[NFS] Start: "
    if "%result%" == "INFO:" (
        start "" "%~dp0winnfsd" -log off -pathFile %2
        echo "started"
    ) else (
        echo "already running"
    )
)

if "%1"=="halt" (
    echo "[NFS] Halt: "
    if "%result%" == "INFO:" (
        echo "not running"
    ) else (
        taskkill /f /im "winnfsd.exe" >nul
        echo "halt"
    )
)
