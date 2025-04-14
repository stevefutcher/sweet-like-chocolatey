$output = [System.IO.Path]::Combine($PSScriptRoot, 'packages', (Get-Date -Format 'yyyyMMddHHmmss'))
New-Item -Path $output -ItemType Directory

$nuspec = "$PSScriptRoot\dnn-iis.nuspec"
choco pack $nuspec --outputdirectory $output

$package = Get-ChildItem $output

nuget push -source cocoa -apiKey az $package.FullName