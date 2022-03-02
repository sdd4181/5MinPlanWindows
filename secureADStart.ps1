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

foreach ($user in enabledUsers) {
    Disable-ADAccount -Identity $user
    remove-adgroupmember -identity Administrators -members $user -verbose -confirm:$false
}

