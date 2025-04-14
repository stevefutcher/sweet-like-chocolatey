# Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Visual Studio
# https://learn.microsoft.com/en-us/visualstudio/install/workload-and-component-ids?view=vs-2022
$config = 'C:\VS-Config\Professional2022.vsconfig'
New-Item $config  -ItemType File -Force -ErrorAction SilentlyContinue
Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/stevefutcher/sweet-like-chocolatey/refs/heads/main/dev-machine-demo/Professional2022.vsconfig' -OutFile $config

choco upgrade visualstudio2022professional -y --package-parameters "--config C:\VS-Config\Professional2022.vsconfig --passive"

#Azure Development
choco upgrade azure-cli -y
choco upgrade microsoftazurestorageexplorer -y

#Other IDEs 
#choco upgrade jetbrains-rider -y
choco upgrade vscode -y

#Other Software
choco upgrade postman -y #ReST Client
choco upgrade googlechrome -y --ignore-checksums # Chrome updates _very_ frequently
choco upgrade firefox -y #Alternative browser that isn't Chrome flavoured :)
choco upgrade keepass -y #Password manager
choco upgrade 7zip -y #Archive tool
#choco upgrade docker-desktop -y #Containers
choco upgrade winscp -y #FTP Client
choco upgrade fiddler -y # Proxy