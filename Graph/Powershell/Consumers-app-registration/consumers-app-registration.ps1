
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
Import-Module PSGraph

function New-Edge ($From, $To, $Attributes, [switch]$AsObject) {
    $null = $PSBoundParameters.Remove('AsObject')
    $ht = [Hashtable]$PSBoundParameters
    if ($AsObject) {
        return [PSCustomObject]$ht
    }
    return $ht
}

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

function Get-GraphVisual ($Name, $Nodes, $Edges, [switch]$Undirected) {
    $sb = {
        if ($Undirected) { inline 'edge [arrowsize=0]' }
        foreach ($node in $Nodes) {
            node @node
        }
        foreach ($edge in $Edges) {
            edge @edge
        }
    }
    graph $sb
}

Connect-MgGraph

# Get all app registrations
$appRegistrations = Get-MgApplication -All 

# Output the target app information
$targetApp = $appRegistrations | Where-Object {
    $_.AppId -eq $TargetAppId
} | Select-Object -First 1 DisplayName, AppId

Write-Output $targetApp

$consumers = Get-Consumers -appId $TargetAppId -allApps $appRegistrations
$consumersQueue = New-Object System.Collections.Generic.Queue[System.Object]
foreach ($consumer in $consumers) {
    $consumersQueue.Enqueue($consumer)
}

$edges = $consumers | ForEach-Object {
    New-Edge -From $_.DisplayName -To $targetApp.DisplayName
}

$edgesList = New-Object System.Collections.Generic.List[System.Object]
if ($edges) {
    $edgesList.AddRange($edges)
}
else {
    $noConsumerEdge = New-Edge -From "No consumers" -To $targetApp.DisplayName
    $edgesList.Add($noConsumerEdge)
}

Write-Output ""
Write-Output "Is used by:"

if (!$InDepthSearch) {
    $consumers | Select-Object DisplayName, AppId
    Get-GraphVisual Consumers -Edges $edgesList.ToArray() | Export-PSGraph
    return
}

# Output the filtered app registrations
$edgesProcessed = New-Object System.Collections.Generic.List[string]

while ($consumersQueue.Count -gt 0) {
    $consumer = $consumersQueue.Dequeue()
    $subConsumers = Get-Consumers -appId $consumer.AppId -allApps $appRegistrations

    Write-Output ""
    Write-Output $consumer

    if ($subConsumers.Count -gt 0) {
        Write-Output ""
        Write-Output "Which is used by:"

        $subConsumers | Select-Object DisplayName, AppId

        foreach ($subConsumer in $subConsumers) {
            $subConsumerEdge = New-Edge -From $subConsumer.DisplayName -To $consumer.DisplayName
            if($edgesProcessed -notcontains $subConsumer.DisplayName + $consumer.DisplayName) {
                $edgesList.Add($subConsumerEdge)
                $consumersQueue.Enqueue($subConsumer)
                $edgesProcessed.Add($subConsumer.DisplayName + $consumer.DisplayName)
            }
            # $edgesList.Add($subConsumerEdge)
        }
    }
    else {
        Write-Output ""
        Write-Output "No consumers"
    }
    
}

# foreach ($consumer in $consumers) {
#     $subConsumers = Get-Consumers -appId $consumer.AppId -allApps $appRegistrations

#     Write-Output ""
#     Write-Output $consumer

#     if ($subConsumers.Count -gt 0) {
#         Write-Output ""
#         Write-Output "Which is used by:"

#         $subConsumers | Select-Object DisplayName, AppId
#         $edges = $subConsumers | ForEach-Object {
#             New-Edge -From $_.DisplayName -To $consumer.DisplayName
#         }
#         $edgesList.AddRange($edges)
#     }
#     else {
#         Write-Output ""
#         Write-Output "No consumers"
#     }
# }

Get-GraphVisual Consumers -Edges $edgesList.ToArray() | Export-PSGraph
