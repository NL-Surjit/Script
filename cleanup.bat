@echo off
setlocal EnableDelayedExpansion

:: Elevate to Admin
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrator access...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Simulated Progress Bar Function
:progress
set /a totalSteps=%1
set /a barWidth=50
set /a i=1

:progress_loop
cls
set /a percent=(!i!*100)/%totalSteps%
set /a filled=(!i!*%barWidth%)/%totalSteps%
set "bar="
for /L %%j in (1,1,!filled!) do set "bar=!bar!█"
for /L %%j in (!filled!,1,%barWidth%) do set "bar=!bar!░"
echo.
echo  [!bar!] !percent!%% Complete
echo.

if !i! GEQ %totalSteps% goto :eof
timeout /nobreak /t 1 >nul
set /a i+=1
goto progress_loop

:: End Function
goto :eof

:: Begin Uninstall Process
cls
echo ============================================
echo  Microsoft Bloatware Removal In Progress...
echo ============================================
echo.

:: List of apps to uninstall
setlocal enabledelayedexpansion
set i=0
set total=50

set "apps[0]=Microsoft 365"
set "apps[1]=Microsoft 365 (Office)"
set "apps[2]=Microsoft Bing Search"
set "apps[3]=Microsoft 365 Apps for enterprise - en-us"
set "apps[4]=Microsoft 365 Apps for enterprise - en-gb"
set "apps[5]=Microsoft 365 Apps for enterprise - th-th"
set "apps[6]=Microsoft 365 Apps ??? - zh-tw"
set "apps[7]=Microsoft 365 ????? - zh-cn"
set "apps[8]=??????? Microsoft 365 ? - ko-kr"
set "apps[9]=Microsoft OneNote - en-gb"
set "apps[10]=Microsoft OneNote - en-us"
set "apps[11]=Microsoft OneNote - ko-kr"
set "apps[12]=Microsoft OneNote - th-th"
set "apps[13]=Microsoft OneNote - zh-cn"
set "apps[14]=Microsoft OneNote - zh-tw"
set "apps[15]=Feedback Hub"
set "apps[16]=Journal"
set "apps[17]=Microsoft News"
set "apps[18]=Microsoft OneDrive"
set "apps[19]=Microsoft Teams"
set "apps[20]=Outlook"
set "apps[21]=Solitaire & Casual Games"
set "apps[22]=Xbox"
set "apps[23]=Xbox Live"
set "apps[24]=Microsoft Office"
set "apps[25]=Office"
set "apps[26]=Word"
set "apps[27]=Excel"
set "apps[28]=PowerPoint"
set "apps[29]=Publisher"
set "apps[30]=Access"
set "apps[31]=Teams"
set "apps[32]=OneDrive"
set "apps[33]=Cortana"
set "apps[34]=People"
set "apps[35]=Your Phone"
set "apps[36]=Get Help"
set "apps[37]=Get Started"
set "apps[38]=Microsoft To Do"
set "apps[39]=Weather"
set "apps[40]=Skype"
set "apps[41]=Zune Music"
set "apps[42]=Zune Video"
set "apps[43]=Xbox Console Companion"
set "apps[44]=Xbox Game Bar"

:uninstall_loop
if defined apps[%i%] (
    set "app=!apps[%i%]!"
    echo Uninstalling !app! ...
    winget uninstall --name "!app!" --silent >nul 2>&1
    set /a i+=1
    call :progress 45
    goto :uninstall_loop
)

:: PowerShell fallback cleanup
echo.
echo Running PowerShell fallback...
powershell -Command ^
"Get-Package | Where-Object { ($_.Name -like '*Office*') -or ($_.Name -like '*OneNote*') -or ($_.Name -like '*Microsoft*') -or ($_.Name -like '*Teams*') -or ($_.Name -like '*Xbox*') } | ForEach-Object { Write-Host 'Uninstalling:' $_.Name; try { Uninstall-Package -Name $_.Name -Force -Confirm:$false -ErrorAction SilentlyContinue } catch {} }"

:: Clean junk files
echo.
echo Cleaning junk (Temp, Prefetch, Cache)...
del /f /s /q "%TEMP%\*.*" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1
md "%TEMP%" >nul 2>&1
rd /s /q "%SystemRoot%\Temp" >nul 2>&1
rd /s /q "%SystemDrive%\Temp" >nul 2>&1
del /f /s /q C:\Windows\Prefetch\*.* >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Windows\WebCache\*.*" >nul 2>&1
del /f /s /q "%LocalAppData%\Temp\*.*" >nul 2>&1
del /f /s /q "%SystemRoot%\Logs\*.*" >nul 2>&1
wsreset.exe >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1

echo.
echo ================================
echo All cleanup tasks completed ✅
echo ================================
pause
