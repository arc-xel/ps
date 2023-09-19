<#
Purpose = delete registry keys of broken KMS connection
Design by GSS
#>

# Get the registry property value
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
$propertyNames = "KeyManagementServiceName","KeyManagementServicePort"

foreach ($propertyName in $propertyNames){

$propertyValue = Get-ItemProperty -Path $registryPath | Select-Object -ExpandProperty $propertyName
$propertyValue

# Delete the registry property using the pipeline
if ($propertyValue -ne $null) {
    Get-ItemProperty -Path $registryPath | Remove-ItemProperty -Name $propertyName #-Force
    Write-Host "Registry property '$propertyName' has been deleted."
} else {
    Write-Host "Registry property '$propertyName' does not exist."
}

}
