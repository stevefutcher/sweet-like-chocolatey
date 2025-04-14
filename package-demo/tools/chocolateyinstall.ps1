$ErrorActionPreference = 'Stop';
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$sourceFile = Join-Path $toolsDir 'iisstart.htm'
$destinationFolder = "C:\inetpub\wwwroot"

Rename-Item "$destinationFolder\iisstart.htm" 'iisstart-backup.htm' -ErrorAction SilentlyContinue

New-Item $destinationFolder -ItemType Directory -ErrorAction SilentlyContinue

Copy-Item $sourceFile $destinationFolder -Force

Write-Output "Hello Dot Net North"