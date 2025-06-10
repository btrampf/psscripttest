function Get-FilePermissonAudit {
    param (
        [Parameter (Mandatory = $true)]
        [string] $ComputerName
    )
    Write-Verbose "Finding Permission Changes"

    #get file permissions changes in that the last 24 hours
    $Yesterday = (Get-Date).AddDays(-1) #- (New-TimeSpan -Day 1)
    $events = Get-WinEvent -FilterHashtable @{logname = 'Security'; id = 4670; StartTime = $Yesterday }

    #create a hashtable and store nested empty array
    $change = @{ Data = @() }

    foreach ($event in $events) {

        Write-Verbose "Converting Events to XML"

        #convert events to xml for ease of use
        [xml]$xmlevent = $event.ToXml()

        #only continue if event is related to files in C:\Projects
        if ($xmlevent.Event.EventData.Data[6].'#text' -match 'C:\\Project') {

            #convert event ACL data to readable format
            $oldSD = ConvertFrom-SddlString $xmlevent.Event.EventData.Data[8].'#text'
            $newSD = ConvertFrom-SddlString $xmlevent.Event.EventData.Data[9].'#text'

            #compare the changes of the old ACL and new ACL
            $diffSD = Compare-Object -ReferenceObject $oldSD.DiscretionaryAcl -DifferenceObject $newSD.DiscretionaryAcl

            #iterate data input for nested hashtable event values within data array
            $change.Data += @{
                'Editor Username'     = $xmlevent.Event.EventData.Data[1].'#text'
                'File Edited'         = $xmlevent.Event.EventData.Data[6].'#text'
                'Old Permissions'     = $oldSD.DiscretionaryAcl
                'New Permissions'     = $newSD.DiscretionaryAcl
                'Permissions Changed' = $diffSD.InputObject
            }
        } #if
    } #foreach

    $psobj = [pscustomobject] $change

    $psobj.data | Format-Table
} #function

Get-FilePermissonAudit -Computername 'PS025492'
$psobj.data | ConvertTo-Json | Out-File 'C:\Projects\test.json'
$change.data | ForEach-Object { [pscustomobject]$_ } | Export-CSV -Path 'C:\Projects\test.csv'