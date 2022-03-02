#getting list of users (store in $rest)
$users = net user
$users = -split $users
$a, $b, $c, $d, $e, $q, $w, $rest = $users

#getting list of administrators (store in $remainingAdmin)
$admin = net localgroup Administrators
$admin = -split $admin
$a, $b, $c, $d, $e, $q, $w, $f, $g, $h, $j, $k, $l, $m, $n, $o, $p, $remainingAdmin = $admin


#getting the one user that we create and want to use
$liveUser = Read-Host "Enter Username" 
$pass = Read-Host "Password" -AsSecureString


New-LocalUser $liveUser -Password $pass -FullName "Origin User" | Out-Null
Add-LocalGroupMember -Group "Administrators" -Member $liveUser | Out-Null
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $liveUser | Out-Null


foreach ($user in $remainingAdmin | Select-Object -SkipLast 5) {
    Write-Output $user
    elseif ($user -ne "Administrator") {
        Remove-LocalGroupMember -Group "Administrators" -Member $user   
    }

}



foreach ($user in $rest | Select-Object -SkipLast 5) {
    if(!$isWhiteList) {
        if ($user -eq "Administrator") {
            net user $user /active:no /time: | Out-Null
        }
        else {
            netuser $user /active:no /passwordchg:no /time: | Out-Null
            }

    }
    
    
    
}


Rename-LocalUser -Name "Administrator" -NewName "Admimistrator"





#if the operating system is 64 bit
if ([Environment]::Is64BitOperatingSystem) {

    #wireshark download
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/64Bit/Wireshark-win64-3.6.2.exe', 'C:\binaries\wiresharkInstall.exe')
    Write-Output "Downloading Wireshark"
    Start-Sleep -Seconds 3
    iex 'C:\binaries\wiresharkInstall.exe'

    #procmon download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/64Bit/Procmon64.exe', 'C:\binaries\Procmon64.exe')
    Write-Output "Downloading Process Monitor"
    iex 'C:\binaries\Procmon64.exe'

    #procexp download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/64Bit/procexp64.exe', 'C:\binaries\Procexp64.exe')
    Write-Output "Downloading Process Explorer"
    iex 'C:\binaries\Procexp64.exe'
}

else {

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/32Bit/Wireshark-win32-3.6.2.exe', 'C:\binaries\wiresharkInstall.exe')
    Write-Output "Downloading Wireshark"
    Start-Sleep 3
    iex 'C:\binaries\wiresharkInstall.exe'

    #procmon download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/32Bit/Procmon.exe', 'C:\binaries\Procmon.exe')
    Write-Output "Downloading Process Monitor"
    iex 'C:\binaries\Procmon64.exe'

    #procexp download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/32Bit/procexp.exe', 'C:\binaries\Procexp.exe')
    Write-Output "Downloading Process Explorer"
    iex 'C:\binaries\Procexp.exe'

}





#Block all ports
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

#Allow firefox
netsh advfirewall firewall add rule name="Allow Firefox" dir=in action=allow program="C:\Program Files\Mozilla Firefox\firefox.exe" enable=yes profile=any
netsh advfirewall firewall add rule name="Allow Firefox" dir=out action=allow program="C:\Program Files\Mozilla Firefox\firefox.exe" enable=yes profile=any
#Allow DNS
netsh advfirewall firewall add rule name=AdClient dir=out protocol=tcp remoteport=53 action=allow
netsh advfirewall firewall add rule name=AdClinet dir=in protocol=tcp remoteport=53 action=allow
#

netsh advfirewall reset







