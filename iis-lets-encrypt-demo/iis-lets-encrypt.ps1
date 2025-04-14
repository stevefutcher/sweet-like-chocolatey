param (
    # The fully qualified domain name 
    [string]$fqdn
)

if ([Net.ServicePointManager]::SecurityProtocol.ToString().Split(',').Trim() -notcontains 'Tls12') {
    [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
}

# Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# Add custom feed
choco source add -n cocoa --source 'https://pkgs.dev.azure.com/stevefutcher/chocaholic/_packaging/cocoa/nuget/v3/index.json'


# Don't require '-y' after every package installation
choco feature enable -n=allowGlobalConfirmation

# Install IIS - from windows features
choco install IIS-WebServerRole --source windowsFeatures

# Create some bindings with your FQDN
New-WebBinding -Name 'Default Web Site' -IPAddress '*' -Port 80 -HostHeader $fqdn
New-WebBinding -Name 'Default Web Site' -IPAddress '*' -Port 443 -HostHeader $fqdn -Protocol https

# Install WinAcme
choco install win-acme

# Run WinAcme using IIS plugins
Start-Process C:\tools\win-acme\wacs.exe `
  -ArgumentList "--source iis --siteid s --accepttos --emailaddress not.a.real.person@outlook.com --installation iis --installationsiteid s" -Wait

# Install Dot Net North demo package  
choco install dnn-iis --source cocoa  

