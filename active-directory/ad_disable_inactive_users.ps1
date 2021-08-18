Import-Module ActiveDirectory

$importCSV = $true
$CSVFile = ".\inactive_users.csv"

### Domain Information ###
# Domain DN
$DomainDN = "dc=internaldomain,dc=net"
# OU to search for inactive users.
$SourceOU = "ou=activeusersOU," + $DomainDN
# OU to put inactive users.
$InactiveOU = "ou=DisabledUsers," + $DomainDN

# Days Inactive
$daysInactive = 90
$Time = (get-Date).Adddays(-($DaysInactive))

if ( $importCSV ) {
    Write-host "Importing CSV of user objects to disable."
    Write-host
    $Users = Import-Csv -Delimiter "," -Path $CSVFile 
    foreach ($User in $Users)  
    {  
        $DisplayName = $User.name
        Get-ADUser -filter { DisplayName -eq $DisplayName } | Set-ADUser -Enabled $false
    } 
} 

else {
    write-host "Scanning OU...disabling & moving inactive user objects."
    $Inactive = Get-ADUser -SearchBase $SourceOU -Filter {LastLogonTimeStamp -lt $Time}
    foreach ($user in $Inactive) {
        $user | Set-ADUser -Enabled $false
        Get-ADObject $user | Move-ADObject -TargetPath $InactiveOU
    }
}



