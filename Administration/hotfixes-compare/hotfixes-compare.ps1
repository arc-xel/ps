#You can either run it as a user that is administrator on both machines, or use the -Credential option on the get-hotfix commands.

$server1 = Read-Host "Server 1"
$server2 = Read-Host "Server 2"
$server1Patches = get-hotfix -computer $server1 | Where-Object {$_.HotFixID -ne "File 1"}
$server2Patches = get-hotfix -computer $server2 | Where-Object {$_.HotFixID -ne "File 1"}
Compare-Object ($server1Patches) ($server2Patches) -Property HotFixID

# Another way

clear-host
$machine1=Read-Host "Enter Machine Name 1"
$machine2=Read-Host "Enter Machine Name 2"
$machinesone=@(Get-wmiobject -computername  $machine1 -Credential Domain\Adminaccount -query 'select hotfixid from Win32_quickfixengineering')
$machinestwo=@(Get-WmiObject -computername $machine2  -Credential Domain\Adminaccount -query 'select hotfixid from Win32_quickfixengineering')
Compare-Object -RefernceObject $machinesone -DiffernceObject $machinestwo -Property hotfixid

