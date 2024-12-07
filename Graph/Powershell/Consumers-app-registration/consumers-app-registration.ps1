[CmdletBinding()]
<#
.SYNOPSIS
This script registers a consumer application in Azure AD.

.PARAMETER TargetAppId
Specifies the target application ID for the consumer app registration. This parameter is mandatory.

.PARAMETER InDepthSearch
Indicates whether to perform an in-depth search. This is an optional switch parameter with a default value of $false.

#>
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