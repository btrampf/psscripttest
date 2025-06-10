$datetime = Get-Date  -UFormat "%m%d%y_%I%M"
$newchange = "FileChanges_$datetime.csv"
$project = 'C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Projects'
$logs = 'C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Logs'
$logfile = 'Log_File.csv'
<# establish current state. Must have a current file 
$currentstate | Export-Csv -Path $logs\$logfile #>

$currentstate = Get-ChildItem -Recurse -Path $project
$items = "$logs\$logfile"

if (Test-Path $items) {
    $previousState = Import-csv -path $items
}

$properties = @('Name')

$compare = @{
    ReferenceObject  = $previousState
    DifferenceObject = $currentstate
    Property         = $properties
    SyncWindow       = 1000
}

$results = Compare-Object @compare | Sort-Object -Property $properties

#reestablish current state
$currentstate | Export-csv -Path $items

if ($results.count -ne 0) {
    # Write-Output "There were $($results.count) file changes"
    Write-Output -InputObject ('There were {0} file changes' -f $results.count)

    # $results | Export-csv -Path "$logs\$newchange"
    $results | Export-csv -Path (join-path -Path $logs -ChildPath $newchange)

    Write-Output 'Writing Logfile'

    $remfiles = $results | Where-Object -Property SideIndicator -EQ '<=' | Select-Object -Property Name
    foreach ($file in $remfiles) {
        Write-Output  "$($file.name) was removed from $project"
    }

    $newfiles = $results | Where-Object -Property SideIndicator -EQ '=>' | Select-Object -Property Name
    foreach ($file in $newfiles) {
        Write-Output  "$($file.name) was added to $project"
    }
}
else {
    Write-Output  "There were no file changes"
}