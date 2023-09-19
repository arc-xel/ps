<#
Purpose = Get-ScheduleTask from remote server
Design by GSS
#>

#Local variables
#$Computername = "ServerName" #uncomment for take from specific server
$PathServers = $PSScriptRoot + "\servers.txt"
$Path = $PSScriptRoot + "\log\" + "$Server.txt"
$Servers = Get-Content $PathServers


Foreach ($Server in $Servers){

#Run command on remote server
$Output = Invoke-Command -ComputerName $Server -ScriptBlock `
        {
#Variables
#use if required specific task name
#$taskname       = "MicrosoftAppletInstallation"
#$ScheduledTask  = Get-scheduledtask | ? {($_.Taskname -like $taskname) -and ($_.TaskPath -eq "\")} 
$ScheduledTasks = Get-ScheduledTask | where{$_.TaskPath -eq "\"}

#Get all task from root folder
#$ScheduledTasks

#Get all properties from required task
$ScheduledTasks | Get-ScheduledTaskInfo | select TaskName,LastRunTime,NextRunTime | ft -AutoSize


foreach ($item in $ScheduledTasks) `
        {

    [string]$Name          = ($item.TaskName)
    [string]$Action        = ($item.Actions | select -ExpandProperty Execute)
    [string]$Author        = ($item.Author)
    [datetime]$Start       = ($item.Triggers | select -ExpandProperty StartBoundary)
    [string]$Repetition    = ($item.Triggers.Repetition | select -ExpandProperty interval)
    [string]$Duration      = ($item.triggers.Repetition | select -ExpandProperty duration)
    [string]$RunAsAccount  = ($item.Principal | select -ExpandProperty UserId)
    [string]$Description   = ($item.Description)
    [string]$State         = ($item.State)

#create hashtable
    $splat = @{

    'Name'           = $Name
    'Action'         = $Action
    'Author'         = $Author
    'Start'          = $start
    'Repetition'     = $Repetition
    'Duration'       = $Duration
    'RunAsAccount'  =  $RunAsAccount
    'Description'    = $Description
    'State'          = $State
              }

    $obj = New-Object -TypeName PSObject -property $splat
    $obj | Write-Output
    #$obj | Export-Csv $PSScriptRoot\$Computername.csv -NoTypeInformation
        }
    
#Delete variables
Remove-Variable * -ErrorAction SilentlyContinue; Remove-Module *; $error.Clear();
        }
    
     $Output | Out-File $PSScriptRoot\$Server_out.txt -Append #-NoTypeInformation
    }
   
