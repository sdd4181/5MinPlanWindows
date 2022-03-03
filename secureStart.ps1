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
$defaultPass = Read-Host "enter the default password for disabled users" -AsSecureString


New-LocalUser $liveUser -Password $pass -FullName $liveUser | Out-Null
Add-LocalGroupMember -Group "Administrators" -Member $liveUser | Out-Null
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $liveUser | Out-Null


foreach ($user in $remainingAdmin | Select-Object -SkipLast 5) {
    Write-Output $user
    if ($user -ne "Administrator") {
        Remove-LocalGroupMember -Group "Administrators" -Member $user   
    }

}



foreach ($user in $rest | Select-Object -SkipLast 5) {
    if(!$isWhiteList) {
        if ($user -eq "Administrator") {
            net user $user $defaultPass /active:no /time: | Out-Null
        }
        else {
            net user $user $defaultPass /active:no /passwordchg:no /time: | Out-Null
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




#enable all (run as admin) prompts to ask for password
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f



#turn on firewall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True

#blocking all icmp
netsh advfirewall firewall add rule name="ICMP block echo requests" protocol=icmpv4:8,any dir=in action=block | Out-Null
netsh advfirewall firewall add rule name="ICMP block echo requests" protocol=icmpv4:8,any dir=in action=block | Out-Null




#used to check if its a domain controller
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if ($osInfo.ProductType -eq 2) {
#if domain controller

    #gets all active AD users
    $enabledUsers = Get-ADUser -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)'


    #creates new AD user
    New-ADUser -Name $liveUser -Accountpassword $pass -Enable $true
    Add-ADGroupMember -Identity Administrators -Members $liveUser
    Add-ADGroupMember -Identity "Domain Admins" -Members $liveUser
    Add-ADGroupMember -Identity "Schema Admins" -Members $liveUser


    #setting up disabled users to also not be able to login at any time during the day even if account got reinabled
    $Hours = New-Object byte[] 21
    $replaceHashTable = New-Object HashTable
    $replaceHashTable.Add("logonHours", $Hours)
    #loops thru all enabled users (except the one I created and disables them)
    foreach ($user in $enabledUsers) {
    Set-ADAccountPassword -Identity $user -NewPassword $defaultPass
        Set-AdUser -Identity $user -Replace $replaceHashTable
        Disable-ADAccount -Identity $user
        if ($user -ne "Administrator") {
            remove-adgroupmember -identity Administrators -members $user -verbose -confirm:$false
        }
    }



    #not tested
    #port that adds uses to communicate which could be helpful
    reg add HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Parameters /v TCP/IP Port /t REG_DWORD /d 2044 /f
    reg add HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters /v DCTcpipPort /t REG_DWORD /d 2045 /f 
    Restart-Service -Name Netlogon -Force



    
}

netsh advfirewall reset | Out-Null
#must restart for reg keys to take effect
Restart-Computer -Force





