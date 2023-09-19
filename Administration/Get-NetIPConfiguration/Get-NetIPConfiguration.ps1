<#
Puprose = Export IP and MAC from list of the servers
Design by GSS
#>

$servers = Get-Content $PSScriptRoot\hosts.csv
$Result =
ForEach ($server in $servers) {
Get-NetIPConfiguration -CimSession $server -detailed | where {$_.InterfaceAlias -eq "vEthernet (LiveMigration)"} | Select computername,IPv4Address,@{N="LinkLayerAddress";E={$_.NetAdapter.LinkLayerAddress}}

}

$Result | out-file -filePath "$PSScriptRoot\ip.csv"# -Append -NoTypeInformation  
Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear();
