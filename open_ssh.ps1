# Variables
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$ssh_folder = "C:\Program Files\OpenSSH-Win64"
$ssh_download_file = $Env:WinDir + "\Temp\OpenSSH.zip"
$ssh_install = 'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'
$ssh_progfolder = $Env:ProgramData + "\ssh"

# How to retrieve the latest OpenSSH package
Write-Output "Retrieving the latest OpenSSH package ..."
$url = 'https://github.com/PowerShell/Win32-OpenSSH/releases/latest/'
$request = [System.Net.WebRequest]::Create($url)
$request.AllowAutoRedirect=$false
$response=$request.GetResponse()
$ssh_download_url = $([String]$response.GetResponseHeader("Location")).Replace('tag','download') + '/OpenSSH-Win64.zip'  

# Download OpenSSH
Write-Output "Downloading $ssh_download_url ..."
(New-Object System.Net.WebClient).DownloadFile($ssh_download_url, $ssh_download_file)

# Decompress OpenSSH
Write-Output "Decompressing OpenSSH ..."
Expand-Archive -Force $ssh_download_file -DestinationPath $Env:Programfiles

# Update Path
Write-Output "Updating Path ..."
$pathMachine = [System.Environment]::GetEnvironmentVariable("Path","Machine")
$pathUser = [System.Environment]::GetEnvironmentVariable("Path","User")
[System.Environment]::SetEnvironmentVariable("Path", $pathMachine + ";" + $ssh_folder, "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $pathUser + ";" + $ssh_folder, "User")

# Install SSH
Write-Output "Installing SSH ..."
Invoke-Expression "&'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'"

# Generate SSH Keys
Write-Output "Generating SSH Keys ..."
New-Item -Path $ssh_progfolder -ItemType Directory
Start-Process -NoNewWindow -FilePath "C:\Program Files\OpenSSH-Win64\ssh-keygen.exe" -ArgumentList "-A"

# Configure Windows Firewall
Write-Output "Configuring Windows Firewall ..."
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Start and Configure OpenSSH Services"
Write-Output "Starting and Configuring OpenSSH Services ..."
Start-Service -Name "sshd"
Start-Service -Name "ssh-agent"
Set-Service -Name "sshd" -StartupType Automatic
Set-Service -Name "ssh-agent" -StartupType Automatic
