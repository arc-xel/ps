<#
Purpose: Add user to administrators group
Created by GSS
#>

#Get list of the servers
$servers = Get-Content "$PSScriptRoot\Servers.csv"

$Result =
ForEach ($server in $servers) {
Invoke-Command -ComputerName $server -ScriptBlock{add-LocalGroupMember -Group "Administrators" -Member "Domain\Username1,Domain\Username2,Domain\Username3"} 
}

#Export of the result to CSV
$Result | export-csv -path "$PSScriptRoot\added_member.csv"
Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear();
