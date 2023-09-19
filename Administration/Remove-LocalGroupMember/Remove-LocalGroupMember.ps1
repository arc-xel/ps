<#
Purpose = Remove local admin from list of computers
by GSS
#>

$servers = Get-Content "$PSScriptRoot\Servers.csv"
$Result = 
ForEach ($server in $servers) `
   {
Invoke-Command -computername $server -ScriptBlock `
    {remove-LocalGroupMember -Group "Administrators" -Member "Domain\Username"}

   }

$Result | export-csv -path "$PSScriptRoot\removed_member.csv"
#Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear();
