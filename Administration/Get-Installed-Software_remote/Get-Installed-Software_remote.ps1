<#
Purpose = Get software from list of remote server and filter them by OS Version
Design by GSS
#>

#Read list of the servers and save it to a massive
$name = Get-Content $PSScriptRoot\Servers_2012.csv

foreach ($server in $name){

Invoke-Command -ComputerName $server -ScriptBlock {

$SCEP = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                    'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction Ignore |
# list only items with a displayname:
Where-Object {$PSItem.DisplayName -like 'System Center Endpoint Protection'} |
# show these registry values per item:
Select-Object -Property DisplayName, DisplayVersion, UninstallString, InstallDate #|

if ($SCEP -ne $null)
{
$OS = (Get-CimInstance Win32_OperatingSystem) | Select-Object Caption, Version
if($OS.Caption -ne "Microsoft Windows Server 2012 R2 Standard")
{
    $OS
    $SCEP
}
else
{continue}
}
else
{continue}
}
}
