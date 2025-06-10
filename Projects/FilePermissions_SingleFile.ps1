
$event = Get-WinEvent -FilterHashtable @{logname = 'Security'; id = 4670 } -MaxEvents 1
[xml]$xmlevent = $event.ToXml()

$oldSD = ConvertFrom-SddlString $xmlevent.Event.EventData.Data[8].'#text'
$newSD = ConvertFrom-SddlString $xmlevent.Event.EventData.Data[9].'#text'

$diffSD = Compare-Object -ReferenceObject $oldSD.DiscretionaryAcl -DifferenceObject $newSD.DiscretionaryAcl

$props = @{ 'Editor Username' = $xmlevent.Event.EventData.Data[1].'#text'
    'File Edited'             = $xmlevent.Event.EventData.Data[6].'#text'
    'Old Permissions'         = $oldSD.DiscretionaryAcl
    'New Permissions'         = $newSD.DiscretionaryAcl
    'Permissions Changed'     = $diffSD.InputObject
}

$psobj = New-Object -Type PSObject -Property $props
    
$psobj | format-list