<#
Puprose = Get list of the servers from OU and check port connectivity from those servers to require server
Design by GSS
#>

#Define local variables

###############################################################################
# Define the OU (Organizational Unit) where you want to get the list of servers
$ouPath = "OU=test,OU=Servers,DC=puppy,DC=com"

#Date
[string]$Hour = get-date -Format "dd.MM.yy-hh.mm"

# Specify the path for the log file
$logFileName = "$Hour" + "_" + "log.txt"

# Specify the path for the log file
$logFilePath = "$PSScriptRoot\Logs\$logFileName"

#Get a list of servers from the specified OU
$servers = Get-ADComputer -Filter * -SearchBase $ouPath

#Get credential
$creds = Get-Credential

# Define the list of ports to test
$ports = 139, 445, 5985

# Define the target server to test the connections to
$targetServer = "targetServer"
###############################################################################


# Loop through each server and test the connections
foreach ($server in $servers.name) {

    #create a remote session
    $Session = New-PSSession -credential $creds -ComputerName $server
    
    Invoke-Command -Session $Session -ScriptBlock {

    # Initialize an empty array to store the results
        $serverName = $using:server
        $connectionResults = @{}
        $results = @()

        
        foreach ($port in $Using:ports) {
        
            $testResult = Test-NetConnection -ComputerName $Using:targetServer -Port $port
            $connectionResults["Port$port"] = $testResult.TcpTestSucceeded
        }
    
        #create a hashtable
        $results += [PSCustomObject]@{
            ServerName        = $serverName
            TargetServer      = $Using:targetServer
            ConnectionResults = $connectionResults | ConvertTo-Json -Compress #-Depth 1
        
        }
   
    
    }

    #get variable from remote session to local session
$Local_results = Invoke-Command -Session $Session -ScriptBlock { $results }
    #Exit and close remote session
$Session  | Disconnect-PSSession | Remove-PSSession

    #Export the results to a log file
$Local_results | Export-Csv -Path $logFilePath -Append -NoTypeInformation

# Display the results in the console (optional)
$Local_results | Format-Table -AutoSize

}

