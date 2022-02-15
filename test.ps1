$users = net user
$users = -split $users
$a, $b, $c, $d, $e, $q, $w, $rest = $users
$pass = Read-Host "Enter Default Password" -AsSecureString
$isWhiteList = $false
[string]$whiteList = Read-Host "Enter the list of users you want to keep running (Don't enter Admin)"
$whiteListArray = $whiteList.split(" ")
#$whiteListArray.Add("Administrator")

$admin = net localgroup Administrators
$admin = -split $admin
$a, $b, $c, $d, $e, $q, $w, $f, $g, $h, $j, $k, $l, $m, $n, $o, $p, $rest = $admin
foreach ($user in $rest | Select-Object -SkipLast 5) {

    foreach ($whiteListMember in $whiteListArray) {
        if ($whiteListMember -eq $user) {
            $isWhiteList = $true
        }
    }
    Write-Output $user
    if ($isWhiteList) {
        $userin = Read-Host "${user} remove from Admin? [Y,N]"
        if ($userin -eq 'Y' -or $userin -eq 'y') {
            Remove-LocalGroupMember -Group "Administrators" -Member $user
            Write-Output "removed from admin"
        }
    }
    elseif ($user -ne "Administrator") {
        Remove-LocalGroupMember -Group "Administrators" -Member $user   
    }
    #Rename-LocalUser -Name "Administrator" -NewName "Admimistrator"

}

$isWhiteList = $false

foreach ($user in $rest | Select-Object -SkipLast 5) {
    Write-Host "${user} and password ${pass}" 

    foreach ($whiteListMember in $whiteListArray) {
        if ($whiteListMember -eq $user) {
            $isWhiteList = $true
        }
    }
    if(!$isWhiteList) {
        if ($user -eq "Administrator") {
            net user $user /active:no /time: | Out-Null
        }
        else {
            netuser $user /active:no /passwordchg:no /time: | Out-Null
            }

    }
    
    
    
}

#Block all ports
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

#Allow firefox
netsh advfirewall firewall add rule name="Allow Firefox" dir=in action=allow program="C:\Program Files\Mozilla Firefox\firefox.exe" enable=yes profile=any
netsh advfirewall firewall add rule name="Allow Firefox" dir=out action=allow program="C:\Program Files\Mozilla Firefox\firefox.exe" enable=yes profile=any
#Allow DNS
netsh advfirewall firewall add rule name=AdClient dir=out protocol=tcp remoteport=53 action=allow
netsh advfirewall firewall add rule name=AdClinet dir=in protocol=tcp remoteport=53 action=allow