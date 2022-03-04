#getting the one user that we create and want to use
$liveUser = Read-Host "Enter Username" 
$pass = Read-Host "Password" -AsSecureString
$defaultPass = Read-Host "enter the default password for disabled users" -AsSecureString


$DisableWinRM = Read-Host "Do you want to fully disable winRM (Y/y)"

#turn on firewall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True | Out-Null

if ($DisableWinRM -eq "Y" -or $DisableWinRM -eq "y") {
    Disable-PSRemoting -Force | Out-Null
    Stop-Service WinRM | Out-Null
    Set-Service WinRM -StartupType Disabled | Out-Null

    #blocking winrm port
    netsh advfirewall firewall add rule name="WinRM" action=block | Out-Null
    reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system /v LocalAccountTokenFilterPolicy /d 0 /t REG_DWORD /f | Out-Null

}


#used to check if its a domain controller
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
if ($osInfo.ProductType -eq 2) {
#if domain controller
    Set-SmbServerConfiguration -RequireSecuritySignature $True -EnableSecuritySignature $True -EncryptData $True -Confirm:$false

    $disableSMB = Read-Host "do you want to disable smb (Y/y)"
    if ($disableSMB -eq "Y" -or $disableSMB -eq "y") {
        reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters /v SMB2 /t REG_DWORD /d 0 /f 
        reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters /v SMB3 /t REG_DWORD /d 0 /f  
    }

    #gets all active AD users
    $enabledUsers = Get-ADUser -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)'


    #creates new AD user
    New-ADUser -Name $liveUser -Accountpassword $pass -Enable $true | Out-Null
    Add-ADGroupMember -Identity Administrators -Members $liveUser | Out-Null
    Add-ADGroupMember -Identity "Domain Admins" -Members $liveUser | Out-Null
    Add-ADGroupMember -Identity "Schema Admins" -Members $liveUser | Out-Null
    Add-ADGroupMember -Identity "Remote Desktop Users" -Members $liveUser | Out-Null


    #setting up disabled users to also not be able to login at any time during the day even if account got reinabled
    $Hours = New-Object byte[] 21
    $replaceHashTable = New-Object HashTable
    $replaceHashTable.Add("logonHours", $Hours)
    #loops thru all enabled users (except the one I created and disables them)
    foreach ($user in $enabledUsers) {
    Set-ADAccountPassword -Identity $user -NewPassword $defaultPass | Out-Null
        Set-AdUser -Identity $user -Replace $replaceHashTable | Out-Null
        Disable-ADAccount -Identity $user | Out-Null
        try {
            remove-adgroupmember -identity Administrators -members $user -verbose -confirm:$false | Out-Null
        }
        catch {

        }
        try {
            remove-adgroupmember -identity "Domain Admins" -members $user -verbose -confirm:$false | Out-Null
        }
        catch {

        }
        try {
            remove-adgroupmember -identity "Schema Admins" -members $user -verbose -confirm:$false | Out-Null
        }
        catch {

        }
        try {
            remove-adgroupmember -identity "Remote Desktop Users" -members $user -verbose -confirm:$false | Out-Null
        }
        catch {

        }
    }



    #not tested
    #port that adds uses to communicate which could be helpful
    reg add HKLM\SYSTEM\CurrentControlSet\Services\NTDS\Parameters /v "TCP/IP Port" /t REG_DWORD /d 2044 /f | Out-Null
    reg add HKLM\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters /v DCTcpipPort /t REG_DWORD /d 2045 /f | Out-Null
    Restart-Service -Name Netlogon -Force



    
}
else {
    #for non DC

    #getting list of users (store in $rest)
    $users = net user
    $users = -split $users
    $a, $b, $c, $d, $e, $q, $w, $rest = $users

    #getting list of administrators (store in $remainingAdmin)
    $admin = net localgroup Administrators
    $admin = -split $admin
    $a, $b, $c, $d, $e, $q, $w, $f, $g, $h, $j, $k, $l, $m, $n, $o, $p, $remainingAdmin = $admin

    



    New-LocalUser $liveUser -Password $pass -FullName $liveUser | Out-Null
    Add-LocalGroupMember -Group "Administrators" -Member $liveUser | Out-Null
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $liveUser | Out-Null


    foreach ($user in $remainingAdmin | Select-Object -SkipLast 5) {
        Write-Output $user
        if ($user -ne "Administrator") {
            Remove-LocalGroupMember -Group "Administrators" -Member $user | Out-Null
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


Rename-LocalUser -Name "Administrator" -NewName "Admimistrator" | Out-Null

}

mkdir C:\monitors | Out-Null

#if the operating system is 64 bit
if ([Environment]::Is64BitOperatingSystem) {

    #wireshark download
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/64Bit/Wireshark-win64-3.6.2.exe', 'C:\monitors\wiresharkInstall.exe')


    #procmon download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/64Bit/Procmon64.exe', 'C:\monitors\mon.exe')



    #procexp download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/64Bit/procexp64.exe', 'C:\monitors\explore.exe')


}

else {

    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/32Bit/Wireshark-win32-3.6.2.exe', 'C:\monitors\wiresharkInstall.exe')


    #procmon download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/32Bit/Procmon.exe', 'C:\monitors\mon.exe')


    #procexp download
    $webClient.DownloadFile('https://github.com/sdd4181/5MinPlanWindows/raw/main/32Bit/procexp.exe', 'C:\monitors\explore.exe')


}




#enable all (run as admin) prompts
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v PromptOnSecureDesktop /t REG_DWORD /d 1 /f | Out-Null
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f | Out-Null

#Secure RDP
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v SecurityLayer /t REG_DWORD /d 2 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f | Out-Null

#Disable RDP
#reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f | Out-Null
#reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v fLogonDisabled /t REG_DWORD /d 1 /f | Out-Null


#Disable SMBv1
reg add HKLM\SYSTEM\CurrentControlSet\Control\Services\LanmanServer\Parameters /v SMB1 /t REG_DWORD /d 0 /f | Out-Null


#Disable sticky keys
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f | Out-Null
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v Flags /t REG_SZ /d 122 /f | Out-Null
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v Flags /t REG_SZ /d 58 /f  | Out-Null


#enable script block logging
reg add HKLM\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging /v EnableModuleLogging /t REG_DWORD /d 1 /f | Out-Null
reg add HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f | Out-Null



#blocking all icmp
netsh advfirewall firewall add rule name="ICMP block echo requests" protocol=icmpv4:8,any dir=in action=block | Out-Null
netsh advfirewall firewall add rule name="ICMP block echo requests" protocol=icmpv6:8,any dir=in action=block | Out-Null











netsh advfirewall reset | Out-Null
#must restart for reg keys to take effect
Restart-Computer -Force





