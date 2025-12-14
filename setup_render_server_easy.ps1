# setup_render_server_easy.ps1
# Extremt enkelt script för att göra Windows 10 Home till privat fjärrserver

function Ask-YesNo($msg) {
    do {
        $ans = Read-Host "$msg (Y/N)"
    } while ($ans -notmatch '^[YyNn]$')
    return $ans -match '^[Yy]$'
}

Write-Host "`n=== Privat Server Setup (Windows 10 Home) ===`n"

# 1. Optimera Windows
if (Ask-YesNo "Optimera Windows för hög prestanda och stäng onödiga bakgrundsappar?") {
    Write-Host "Sätter visuella effekter och energialternativ..."
    # Prestanda: hög
    powercfg -setactive SCHEME_MIN
    # Stoppa bakgrundsappar (förenklad version)
    Get-Process | Where-Object {$_.MainWindowTitle -eq "" -and $_.Name -notin @("explorer","powershell")} | Stop-Process -ErrorAction SilentlyContinue
    Write-Host "Windows optimerat!"
}

# 2. Installera Tailscale
if (Ask-YesNo "Installera Tailscale för säker fjärraccess?") {
    $url="https://pkgs.tailscale.com/stable/tailscale-setup-1.48.3.msi"
    $file="$env:TEMP\tailscale.msi"
    Invoke-WebRequest $url -OutFile $file
    Start-Process msiexec.exe -ArgumentList "/i `"$file`" /quiet /norestart" -Wait
    Write-Host "Tailscale installerat! Logga in manuellt första gången."
}

# 3. Installera Chrome Remote Desktop
if (Ask-YesNo "Installera Chrome Remote Desktop för fjärrskrivbord?") {
    $url="https://dl.google.com/chrome-remote-desktop/chrome-remote-desktop_current_amd64.msi"
    $file="$env:TEMP\crd.msi"
    Invoke-WebRequest $url -OutFile $file
    Start-Process msiexec.exe -ArgumentList "/i `"$file`" /quiet /norestart" -Wait
    Write-Host "Chrome Remote Desktop installerat! Konfigurera manuellt efter första körning."
}

# 4. Autostart för Tailscale
if (Ask-YesNo "Vill du att Tailscale startar automatiskt med Windows?") {
    $tsPath="C:\Program Files (x86)\Tailscale IPN\tailscale.exe"
    if (Test-Path $tsPath) {
        $shell=New-Object -ComObject WScript.Shell
        $startup=[Environment]::GetFolderPath("Startup")
        $lnk=$shell.CreateShortcut("$startup\Tailscale.lnk")
        $lnk.TargetPath=$tsPath
        $lnk.Save()
        Write-Host "Tailscale autostart klar!"
    }
}

# 5. Autostart för Chrome Remote Desktop
if (Ask-YesNo "Vill du att Chrome Remote Desktop startar automatiskt med Windows?") {
    $crdPath="C:\Program Files (x86)\Google\Chrome Remote Desktop\_CRD\CRDHost.exe"
    if (Test-Path $crdPath) {
        $shell=New-Object -ComObject WScript.Shell
        $startup=[Environment]::GetFolderPath("Startup")
        $lnk=$shell.CreateShortcut("$startup\ChromeRemoteDesktop.lnk")
        $lnk.TargetPath=$crdPath
        $lnk.Save()
        Write-Host "Chrome Remote Desktop autostart klar!"
    }
}

Write-Host "`n=== Setup klart! ==="
Write-Host "1) Logga in i Tailscale från laptopen."
Write-Host "2) Konfigurera Chrome Remote Desktop första gången."
Write-Host "3) Din laptop är nu privat server redo att nås från mobilen via Tailscale."
