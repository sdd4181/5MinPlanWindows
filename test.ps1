$users = net user
$users = -split $users
$a, $b, $c, $d, $e, $q, $w, $rest = $users
foreach ($user in $rest | Select-Object -SkipLast 5) {
    #net user $user /passwordchg:no
    $userin = Read-Host "${user} disable? [Y,N]"
    if ($userin -eq "Y" -or $userin -eq "y") {
        net user $user /active:no
    }
    else {
        #$pass = Read-Host "Enter Password for ${user}" -AsSecureString
        #Write-Host "${user} and password ${pass}"
    }
}

#netsh advfirewall set allprofiles state on
$admin = net localgroup Administrators
$admin = -split $admin
$a, $b, $c, $d, $e, $q, $w, $f, $g, $h, $j, $k, $l, $m, $n, $o, $p, $rest = $admin
foreach ($user in $rest | Select-Object -SkipLast 4) {
    #net user $user /passwordchg:no
    $userin = Read-Host "${user} remove from Admin? [Y,N]"
    if ($userin -eq "Y" -or $userin -eq "y") {
        Remove-LocalGroupMember -Group "Administrators" -Member $user
    }
}