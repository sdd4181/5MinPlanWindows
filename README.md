# 5MinPlanWindows
The 5 minute plan for windows

Script asks user to enter a `default password` and a `whitelist`. It turns off all non-whitelisted users and still asks if the runner of the script wants the whitelisted user to be taken off the administrator list. 

Download and run script by running the command below in 

```
powershell.exe -ExecutionPolicy Bypass -NoExit (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/sdd4181/5MinPlanWindows/main/secureStart.ps1', 'C:\Users\%USERNAME%\Desktop\script1.ps1'); iex 'C:\Users\%USERNAME%\Desktop\script1.ps1'

```

```
powershell.exe -ExecutionPolicy Bypass -NoExit (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/sdd4181/5MinPlanWindows/main/secureADStart.ps1', 'C:\Users\%USERNAME%\Desktop\script1.ps1'); iex 'C:\Users\%USERNAME%\Desktop\script1.ps1'

```
