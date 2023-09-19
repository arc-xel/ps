########################
<#
Purpose = Get updates from group of servers
Design by GSS
#>
########################

#Get list of the server to array
$Servers = get-content $PSScriptRoot\Servers.csv

Foreach ($server in $servers)
{
Invoke-Command -ComputerName $server -scriptblock{
Get-HotFix | Where-Object -Property HotfixID -EQ "KB5016058" | ft -Property PSComputerName,Description,HotFixID,InstalledBy,InstalledOn
}
}
$date = get-date -Format "dd.MM.yy hh:mm"
Write-host("`nToday date: $date")
