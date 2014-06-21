@echo off

:: Fancy way to enable command extensions, where available
:: http://technet.microsoft.com/en-us/library/bb491001.aspx OR http://www.robvanderwoude.com/allhelpw2ksp4_en.php#SETLOCAL
verify other 2>nul
    setlocal enableextensions
    if errorlevel 1 echo Unable to enable command extensions

for /f "tokens=1 delims= " %%y in ('tasklist /nh /fi "imagename eq winnfsd.exe"') do @set result=%%y

CALL :LoCase %result

if %1==status (
    echo|set /p=[NFS] Status: 
    
    if "%result%"==winnfsd.exe (
        echo running
        exit 0
    ) else (
        echo halted
        exit 1
    )
)

if %1==start (
    echo|set /p=[NFS] Start: 
    
    if "%result%"==winnfsd.exe (
        echo already running
    ) else (
        start "" "%~dp0winnfsd" -log %2 -pathFile %3 -id %4 %5
        echo started
    )
    
    exit 0
)

if %1==halt (
    echo|set /p=[NFS] Halt: 
    
    if "%result%"==winnfsd.exe (
        taskkill /f /im "winnfsd.exe" >nul
        echo halt
    ) else (
        echo not running       
    )
    
    exit 0
)

exit 1

:LoCase
:: Subroutine to convert a variable VALUE to all lower case.
:: The argument for this subroutine is the variable NAME.
FOR %%i IN ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i" "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r" "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z") DO CALL SET "%1=%%%1:%%~i%%"
GOTO:EOF