<#
Purpose = Import certificate on remote computer
Created By GSS

Based on:
https://geeklifenow.com/2021-06-05-PS-BulkImportCert/
https://livebook.manning.com/book/windows-powershell-in-action-third-edition/chapter-11/340
#>

#List of required servers
$Servers = Get-Content -Path $PSScriptRoot\Servers.txt | Where-Object { $PSItem -notmatch '^\s*$' }

#Date
[string]$Global:Hour = get-date -Format "dd.MM.yy-hh.mm"

#FileName
$Global:Key = New-Object Byte[] 32
$Global:LogName = $Hour + ".txt" 
$Global:LogPath = "$PSScriptRoot" + "\log\" + $LogName
$Global:LogTranscript = "$PSScriptRoot" + "\log\" + "Transcript_" + $hour + ".txt"
$Global:PwdFilePass = "$PSScriptRoot\Keys" + "\Password.key" #store hash password in file
$Global:AesFileKey = "$PSScriptRoot\Keys" + "\AES.key"      #store key in file
$Global:Path = "C:\Temp"
$Global:FilePath = "$Global:Path" + "\wildcard.pfx"
$Global:CertPath = "\\Server\share\wildcard.pfx"

#ShortFileName
$Global:ShortLogName = $Hour + "_ShortLog.txt" 
$Global:ShortLogPath = $PSScriptRoot + "\log\" + $ShortLogName

Start-Transcript -Path $Global:LogTranscript -NoClobber
#####################################
#Creating AES key with random data. Require when password was changed
#[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Global:Key) 
#$Global:Key | out-file $Global:AesFileKey

#Get Credentials and save it to the file. Require when password was changed
#$Global:Credential = Read-Host -Prompt "Please enter the password of PFX file" -AsSecureString
#$Global:Credential | ConvertFrom-SecureString -Key $Global:Key | Out-File $PwdFilePass
######################################
#Get Credentials from file and convert it to secure string
$Global:Key = Get-Content $Global:AesFileKey 
$Global:password = Get-Content $Global:PwdFilePass
$Global:password = $Global:password | ConvertTo-SecureString -Key $Global:Key


foreach ($Server in $Servers) {

    #Open a remote session
    $session = New-PSSession -ComputerName $Server
    Write-Output("$Hour OK: Session $session") | Out-File $Global:LogPath -Append
    
    #Create a folder if not exist
    $TempFolder = Invoke-Command -Session $session -ScriptBlock `
    {
            
            if (-not(Test-Path $Using:Path))
            {
            Write-Output("$Using:Hour OK:Creating folder $using:Path")
            New-Item -Path $Using:Path -ItemType Directory -force  | Out-Null
        }
        else {
            Write-Output("$Using:Hour Error:The folder $using:Path already exists")
        }
    }
    #save output from remote session to log
    $TempFolder | Out-File $Global:LogPath -Append

    #Copy pfx file on remote server
    Copy-Item -Path $CertPath -ToSession $session -Destination $Global:Path

    $ImportCert = Invoke-Command -Session $session -ScriptBlock `
    {
        #Import Certificate
        Import-PFXCertificate -Password $using:password -CertStoreLocation Cert:\LocalMachine\My -FilePath $using:FilePath
        
        #Check certificates
        Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Issuer -like "*Thawte*"} | Select-Object Notafter, Subject

        #Delete pfx file from remote server
        Remove-Item -Path $using:FilePath -force

        #check certificate was removed
        $TestFile = Test-Path $using:FilePath
        Write-Output("$Using:Hour OK:PFX file $using:FilePath is exist - $TestFile")
    }
    #Delete remote session
    $Removed = Remove-PSSession $session
    Write-Output("$Hour OK: Session $Removed ") | Out-File $Global:LogPath -Append

    #save output from remote session to log
    $ImportCert | Out-File $Global:LogPath -Append

}

Stop-Transcript
