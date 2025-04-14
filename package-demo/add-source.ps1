$pat = Read-Host "Enter PAT"
nuget.exe sources add -name cocoa -source https://pkgs.dev.azure.com/stevefutcher/chocaholic/_packaging/cocoa/nuget/v3/index.json -Username az -Password "$pat"