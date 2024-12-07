[CmdletBinding()]
<#
.SYNOPSIS
Script to map the consumers of an application registration.

.PARAMETER TargetAppId
Define the client ID of the app registration you are interested in.

.PARAMETER InDepthSearch
Indicates whether to perform an in-depth search. This is an optional switch parameter with a default value of $false.

#>
param (
    [Parameter(Mandatory)]
    [string]
    $TargetAppId,

    [Parameter()]
    [switch]
    $InDepthSearch = $false
)

function Get-Consumers {
    param (
        [string]$appId,
        [array]$allApps
    )
    $filteredApps = $allApps | Where-Object {
        $_.RequiredResourceAccess.ResourceAppId -match $appId
    }    

    return $filteredApps
}

Connect-MgGraph

# Get all app registrations
$appRegistrations = Get-MgApplication -All 

# Output the target app information
$appRegistrations | Where-Object {
    $_.AppId -match $TargetAppId
} | Select-Object DisplayName, AppId 

$consumers = Get-Consumers -appId $TargetAppId -allApps $appRegistrations

Write-Output ""
Write-Output "Is used by:"

if (!$InDepthSearch) {
    $consumers | Select-Object DisplayName, AppId
    return
}

# Output the filtered app registrations
foreach ($consumer in $consumers) {
    $subConsumers = Get-Consumers -appId $consumer.AppId -allApps $appRegistrations

    Write-Output ""
    Write-Output $consumer

    if ($subConsumers.Count -gt 0) {
        Write-Output ""
        Write-Output "Which is used by:"

        $subConsumers | Select-Object DisplayName, AppId
    }
    else {
        Write-Output ""
        Write-Output "No consumers"
    }
}