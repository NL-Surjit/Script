@echo off
:: Elevate to Administrator
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Administrative privileges required.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo =============================================
echo  Removing Microsoft Bloatware & System Junk
echo =============================================
echo.

:: Full bloatware removal list
for %%A in (
    "Microsoft 365"
    "Microsoft 365 (Office)"
    "Microsoft Bing Search"
    "Microsoft 365 Apps for enterprise - en-us"
    "Microsoft 365 Apps for enterprise - en-gb"
    "Microsoft 365 Apps for enterprise - th-th"
    "Microsoft 365 Apps ??? - zh-tw"
    "Microsoft 365 ????? - zh-cn"
    "??????? Microsoft 365 ? - ko-kr"
    "Microsoft OneNote - en-gb"
    "Microsoft OneNote - en-us"
    "Microsoft OneNote - ko-kr"
    "Microsoft OneNote - th-th"
    "Microsoft OneNote - zh-cn"
    "Microsoft OneNote - zh-tw"
    "Feedback Hub"
    "Journal"
    "Microsoft News"
    "Microsoft OneDrive"
    "Microsoft Teams"
    "Outlook"
    "Solitaire & Casual Games"
    "Xbox"
    "Xbox Live"
    "Microsoft Office"
    "Office"
    "Word"
    "Excel"
    "PowerPoint"
    "Publisher"
    "Access"
    "Teams"
    "OneDrive"
    "Cortana"
    "People"
    "Your Phone"
    "Get Help"
    "Get Started"
    "Microsoft To Do"
    "Weather"
    "Skype"
    "Zune Music"
    "Zune Video"
    "Xbox Console Companion"
    "Xbox Game Bar"
) do (
    echo Attempting to uninstall %%A via winget...
    winget uninstall --name "%%A" --silent >nul 2>&1
)

:: PowerShell fallback for stubborn packages
echo.
echo Running PowerShell cleanup...
powershell -Command ^
"Get-Package | Where-Object { ($_.Name -like '*Office*') -or ($_.Name -like '*OneNote*') -or ($_.Name -like '*Microsoft*') -or ($_.Name -like '*Teams*') -or ($_.Name -like '*Xbox*') } | ForEach-Object { Write-Host 'Uninstalling:' $_.Name; try { Uninstall-Package -Name $_.Name -Force -Confirm:$false -ErrorAction SilentlyContinue } catch {} }"

:: Junk Cleanup
echo.
echo Cleaning system junk (Temp, Cache, Prefetch, etc.)...

:: Temp files
rd /s /q "%TEMP%" >nul 2>&1
md "%TEMP%" >nul 2>&1
rd /s /q "%SystemRoot%\Temp" >nul 2>&1
rd /s /q "%SystemDrive%\Temp" >nul 2>&1

:: Prefetch
del /f /s /q C:\Windows\Prefetch\*.* >nul 2>&1

:: Windows Store cache
wsreset.exe >nul 2>&1

:: Internet cache and logs
del /f /s /q "%LocalAppData%\Microsoft\Windows\WebCache\*.*" >nul 2>&1
del /f /s /q "%LocalAppData%\Temp\*.*" >nul 2>&1
del /f /s /q "%SystemRoot%\Logs\*.*" >nul 2>&1

:: Start Disk Cleanup
echo Running Disk Cleanup...
cleanmgr /sagerun:1 >nul 2>&1

echo.
echo ===============================
echo  Cleanup & Debloat Completed!
echo ===============================
pause
