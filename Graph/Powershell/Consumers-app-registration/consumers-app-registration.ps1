[CmdletBinding()]
<#
.SYNOPSIS
Script to map the consumers of an application registration.

.PARAMETER TargetAppId
Define the client ID of the app registration you are interested in.
#>
param (
    [Parameter(Mandatory)]
    [string]
    $TargetAppId
)

Connect-MgGraph

# Get all app registrations
$appRegistrations = Get-MgApplication -All 
$filteredApps = $appRegistrations | Where-Object {
    $_.RequiredResourceAccess.ResourceAppId -match $TargetAppId
}

# Output the target app information
$appRegistrations | Where-Object {
    $_.AppId -match $TargetAppId
} | Select-Object DisplayName, AppId 

Write-Output ""
Write-Output "Is used by:"

# Output the filtered app registrations
$filteredApps | Select-Object DisplayName, AppId