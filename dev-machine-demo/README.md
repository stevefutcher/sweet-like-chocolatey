# Dev Machine Setup

To invoke the dev setup script we're going to borrow the chocolatey script invocation

```
Set-ExecutionPolicy Bypass -Scope Process -Force; `
 [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
 iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/stevefutcher/sweet-like-chocolatey/refs/heads/main/dev-machine-demo/DevMachineSetup.ps1'))
```


