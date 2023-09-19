<#
Purpose = Export local administrators from list of computer
Design by GSS
#>

$servers = Get-Content "$PSScriptRoot\Servers.csv"
$Result =
ForEach ($server in $servers) 
{
Invoke-Command -computername $server { Get-LocalGroupMember Administrators } 
}

$Result | export-Excel -path "$PSScriptRoot\Admin_members.xls"
#$Result | ConvertTo-Html -Property PSComputerName,Name,PrincipalSource,ObjectClass | out-file $PSScriptRoot\admins.html


