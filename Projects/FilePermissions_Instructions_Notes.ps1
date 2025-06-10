First Part

1. How to enumerate and understand file and folder permissions on the operating system (Windows)

Use a module called NTFSSecurity

Find-Module -Name NTFSSecurity | Select *
https://github.com/raandree/NTFSSecurity

2. Create a report that displays the permissions

Examples:

Reading the permissions of a single item
Get-Item D:\Data | Get-NTFSAccess
Get-NTFSAccess -Path D:\Data

Reading the permissions of a multiple item
dir C:\Data | Get-NTFSAccess
dir | Get-NTFSAccess –ExcludeInherited
dir | Get-NTFSAccess -Account raandree9\randr_000

Create a report
Get-ChildItem -Path 'C:\Projects' | 
Get-NTFSAccess | Format-TAble


Second Part

1. Create a solution that will montior changes on the file system level that montiors file and folder permissions and report the delta changes 

Example:
Add-NTFSAudit -Path C:\Data -Account 'NT AUTHORITY\Authenticated Users' -AcessRights generic All -AuditFlags Failure

Turning on System Auditing
#https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-10/security/threat-protection/auditing/event-4663
#https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/auditpol
**Must turn on System Security Auditing (Local Policy or Group Policy)**
auditpol /set /Category:'Object Access' /failure:enable /success:enable

Creating an Audit
New-Item -ItemType Directory -Path C:\Projects

Add-NTFSAudit -Path 'C:\Projects' `
-Account 'AVWORLD\bran8994' -AccessRights GenericAll -AuditFlags Failure,Success -Appliesto ThisFolderSubfoldersAndFiles -Passthru

Add-NTFSAudit -Path 'C:\Projects' `
-Account 'AVWORLD\bran8994' -AccessRights ChangePermissions -AuditFlags Failure,Success -Appliesto ThisFolderSubfoldersAndFiles -Passthru

Search an existing NTFSAudit
Get-NTFSAudit -Path 'C:\Projects' -Account 'AVWORLD\bran8994'

Remove NTFSAudits
Remove-NTFSAudit -Path 'C:\Projects' -Account 'AVWORLD\bran8994' -AccessRights FullControl
Remove-NTFSAudit -Path 'C:\Projects' `
-Account 'NT AUTHORITY\Authenticated Users' -AccessRights GenericAll

Query System Security Logs

get-winevent -LogName Security | where { $_.eventid -eq 4663 -and $_.message -match "c:\\Project"}

get-eventlog -LogName security | where { $_.eventid -eq 4663 } |
select-object -ExpandProperty message | select-string -pattern "c:\\Project"

Get-EventLog -LogName Security | where { $_.eventid -eq 4663 -and $_.message -match "c:\\Project"} | Select-Object -Property message


Example Change message

Permissions on an object were changed.

Subject:
	Security ID:		AVWORLD\bran8994
	Account Name:		bran8994
	Account Domain:		AVWORLD
	Logon ID:		0x16F7789

Object:
	Object Server:	Security
	Object Type:	File
	Object Name:	C:\Projects\FilePermissions.ps1
	Handle ID:	0x107c

Process:
	Process ID:	0x1320
	Process Name:	C:\Windows\explorer.exe

Permissions Change:
	Original Security Descriptor:	D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;ID;FA;;;S-1-5-21-2060139532-2050374463-2073913816-240324)
	New Security Descriptor:	D:ARAI(A;;FA;;;BU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;ID;FA;;;S-1-5-21-2060139532-2050374463-2073913816-240324)

How to decipher permission changes in DACL format using ConvertFrom-SddlString

$oldparam = ConvertFrom-SddlString "D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;ID;FA;;;S-1-5-21-2060139532-2050374463-2073913816-240324)"
$newparam = ConvertFrom-SddlString "D:ARAI(A;;FA;;;BU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;ID;FA;;;S-1-5-21-2060139532-2050374463-2073913816-240324)"

Compare-Object -ReferenceObject $oldparam.DiscretionaryAcl -DifferenceObject $newparam.DiscretionaryAcl| format-list


Query the Windows Event logs using XML

$event=Get-WinEvent -FilterHashtable @{logname='Security';id=4670} -MaxEvents 1
[xml]$xmlevent = $event.ToXml()
$eventobj = New-Object System.Management.Automation.PSObject
$eventobj | Add-Member Noteproperty -Name $xmlevent.Event.EventData.Data[1].name -Value $xmlevent.Event.EventData.Data[1].'#text'
$eventobj | Add-Member Noteproperty -Name $xmlevent.Event.EventData.Data[8].name -Value $xmlevent.Event.EventData.Data[8].'#text'
$eventobj | Add-Member Noteproperty -Name $xmlevent.Event.EventData.Data[9].name -Value $xmlevent.Event.EventData.Data[9].'#text'
$eventobj|format-list

Event Schema (XML)

<Event xmlns='http://schemas.microsoft.com/win/2004/08/events/event'>
<System><Provider Name='Microsoft-Windows-Security-Auditing' Guid='{54849625-5478-4994-a5ba-3e3b0328c30d}'/>
<EventID>4670</EventID>
<Version>0</Version>
<Level>0</Level>
<Task>13570</Task>
<Opcode>0</Opcode>
<Keywords>0x8020000000000000</Keywords>
<TimeCreated SystemTime='2025-01-28T13:31:45.6047965Z'/>
<EventRecordID>8112992</EventRecordID>
<Correlation/><Execution ProcessID='4' ThreadID='7816'/>
<Channel>Security</Channel>
<Computer>PS025156.esri.com</Computer>
<Security/></System>
#added array values for clarity
<EventData>
[0]<Data Name='SubjectUserSid'>S-1-5-21-2060139532-2050374463-2073913816-240324</Data>
[1]<Data Name='SubjectUserName'>bran8994</Data>
[2]<Data Name='SubjectDomainName'>AVWORLD</Data>
[3]<Data Name='SubjectLogonId'>0x16f7789</Data>
[4]<Data Name='ObjectServer'>Security</Data>
[5]<Data Name='ObjectType'>File</Data>
[6]<Data Name='ObjectName'>C:\Projects\FilePermissions.ps1</Data>
[7]<Data Name='HandleId'>0x107c</Data>
[8]<Data Name='OldSd'>D:AI(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;ID;FA;;;S-1-5-21-2060139532-2050374463-2073913816-240324)</Data>
[9]<Data Name='NewSd'>D:ARAI(A;;FA;;;BU)(A;ID;FA;;;SY)(A;ID;FA;;;BA)(A;ID;0x1200a9;;;BU)(A;ID;FA;;;S-1-5-21-2060139532-2050374463-2073913816-240324)</Data>
[10]<Data Name='ProcessId'>0x1320</Data><Data Name='ProcessName'>C:\Windows\explorer.exe</Data>
</EventData>
</Event>

1b. As a bonus 

Monitor for file changes and report the details in a seperate or the same report - A lot of detail is good

Part 3.

Monitor a folder for content changes (use native powershell, not ntfssecurity)
-File changes
-File addtions (Adding and subtracting files)
-Bonus: Adding a new Folder or Subfolder

-Deserialize and Serialize using powershell (csv, json preferably)

PArt 4.

Create a cleaner report that describes all the changes, in one single report
Capture file content changes with a boolean value (get-filehash)
Get-Date -Format FileDateTimeUniversal

Part 5.

Become firmiliar with ImportExcel powershell module
Use the module to present the FileChanges in a nice to look at
Notes:
When using Export-Excel (no parameters) exports a excel file and doesnt do anything
When using Export-Excel -Now (switch peramater) adds three key switch parameters by default (-Show, -AutoSize, -AutoFilter)

Example of Splattering a hashtable to Export-Excel

$text1 = New-ConditionalText -Text Removed -ConditonalTextColor Red -Backgroundcolor Black
$text2 = Another Conditional
#Apply formating only on collumn C
$format1 = New-ConditionalFormattingIconSet -Range "C:C" -ConditonalFormat ThreeIconSet -IconType Arrows

$exstyle = @{
	Path = 'C:/Test/Path'
	Show = $false
	AutoSize = $true
	BoldTopRow = $true
	IncludePivotChart = $true
	PivotRows = 'test'
	PivotData = @{datatype = 'data'}
	ConditionalText = @($Text1,$Text2)
	ConditionalFormat = @("$format1")
}
Export-Excel @exstyle



-address "D2:D$Lastrow"