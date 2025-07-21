# Requires Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Host "Relaunching script as Administrator..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "`n-------------------------------"
Write-Host " Removing Microsoft Bloatware "
Write-Host "-------------------------------`n"

# Combine all apps in a single list for progress tracking
$wingetApps = @(
    "Microsoft 365 (Office)",
    "Microsoft Bing Search",
    "Microsoft 365 Apps for enterprise - en-us",
    "Microsoft 365 Apps for enterprise - en-gb",
    "Microsoft 365 Apps for enterprise - th-th",
    "Microsoft 365 Apps ??? - zh-tw",
    "Microsoft 365 ????? - zh-cn",
    "??????? Microsoft 365 ? - ko-kr",
    "Microsoft OneNote - en-gb",
    "Microsoft OneNote - en-us",
    "Microsoft OneNote - ko-kr",
    "Microsoft OneNote - th-th",
    "Microsoft OneNote - zh-cn",
    "Microsoft OneNote - zh-tw",
    "Feedback Hub",
    "Journal",
    "Microsoft News",
    "Microsoft OneDrive",
    "Microsoft Teams",
    "Outlook",
    "Solitaire & Casual Games",
    "Xbox",
    "Xbox Live"
)

$total = $wingetApps.Count
for ($i = 0; $i -lt $total; $i++) {
    $percent = ($i / $total) * 100
    Write-Progress -Activity "Uninstalling bloatware with winget..." -Status "Removing: $($wingetApps[$i])" -PercentComplete $percent
    try {
        winget uninstall --name "$($wingetApps[$i])" --silent --accept-source-agreements --accept-package-agreements
    } catch {
        Write-Warning "Failed to uninstall $($wingetApps[$i]) with winget."
    }
}
Write-Progress -Activity "Uninstalling bloatware with winget..." -Completed

# WMI cleanup for any residual Office/OneNote
Write-Host "`nRunning WMI cleanup for leftover Office/OneNote apps..."
Get-WmiObject -Class Win32_Product |
    Where-Object { $_.Name -like "*Office*" -or $_.Name -like "*OneNote*" -or $_.Name -like "Microsoft 365*" } |
    ForEach-Object {
        Write-Host "Uninstalling via WMI: $($_.Name)"
        $_.Uninstall()
    }

# AppxPackage removal
$storeApps = @(
    "Microsoft.XboxGamingOverlay",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.YourPhone",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.OneConnect",
    "Microsoft.SkypeApp"
)

$total2 = $storeApps.Count
for ($j = 0; $j -lt $total2; $j++) {
    $percent2 = ($j / $total2) * 100
    Write-Progress -Activity "Removing Microsoft Store Apps..." -Status "Uninstalling: $($storeApps[$j])" -PercentComplete $percent2

    Get-AppxPackage -Name $storeApps[$j] -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $storeApps[$j] } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}
Write-Progress -Activity "Removing Microsoft Store Apps..." -Completed

Write-Host "`n✅ All known Microsoft bloatware has been removed (or attempted)."
pause
