$ErrorActionPreference = 'Stop';

$iisFolder = "C:\inetpub\wwwroot"
Rename-Item "$iisFolder\iisstart-backup.htm" 'iisstart.htm' -Force