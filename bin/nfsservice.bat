@echo off
tasklist /nh /fi "imagename eq winnfsd.exe" 2>nul | grep -i -c "winnfsd.exe" >nfsservicetmp
set /p RUNNINGTASKS=<nfsservicetmp
del nfsservicetmp

if %1==status (
    :: printf "[NFS] Status: "
    if %RUNNINGTASKS% == 0 (
        :: printf "halted\n"
        exit 1
    ) else (
        :: printf "running\n"
        exit 0
    )
)

if %1==start (
    printf "[NFS] Start: "
    if %RUNNINGTASKS% == 0 (
        start "" "%~dp0winnfsd" -log off -pathFile %2
        printf "started\n"
    ) else (
        printf "already running\n"
    )
    
    exit 0
)

if %1==halt (
    printf "[NFS] Halt: "
    if %RUNNINGTASKS% == 0 (
        printf "not running\n"
    ) else (
        taskkill /f /im "winnfsd.exe" >nul
        printf "halt\n"
    )
    
    exit 0
)

exit 1