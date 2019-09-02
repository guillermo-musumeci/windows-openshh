# Variables
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$ssh_folder = "C:\Program Files\OpenSSH-Win64"
$ssh_download_file = $Env:WinDir + "\Temp\OpenSSH.zip"
$ssh_download_url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.0.0.0p1-Beta/OpenSSH-Win64.zip"
$ssh_install = 'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'
$ssh_progfolder = $Env:ProgramData + "\ssh"

# Download OpenSSH
Write-Output "Downloading $ssh_download_url"
(New-Object System.Net.WebClient).DownloadFile($ssh_download_url, $ssh_download_file)

# Decompress OpenSSH
Write-Output "Decompress OpenSSH"
Expand-Archive -Force $ssh_download_file -DestinationPath $Env:Programfiles

# Update Path
Write-Output "Update Path"
$pathMachine = [System.Environment]::GetEnvironmentVariable("Path","Machine")
$pathUser = [System.Environment]::GetEnvironmentVariable("Path","User")
[System.Environment]::SetEnvironmentVariable("Path", $pathMachine + ";" + $ssh_folder, "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $pathUser + ";" + $ssh_folder, "User")

# Install SSH
Write-Output "Install SSH"
Invoke-Expression "&'C:\Program Files\OpenSSH-Win64\install-sshd.ps1'"

# Generate SSH Keys
New-Item -Path $ssh_progfolder -ItemType Directory
Start-Process -NoNewWindow -FilePath "C:\Program Files\OpenSSH-Win64\ssh-keygen.exe" -ArgumentList "-A"
