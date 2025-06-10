Get-Command -CommandType Cmdlet, Function | Where-Object {
    $metadata = [System.Management.Automation.CommandMetadata]$_
    $metadata.ConfirmImpact -eq 'High'
    }

Help about_Providers

Get-Help * -Category Provider

Get-ChildItem variable::
Get-ChildItem registry::
Get-Item variable::true

Get-PSProvider
Get-PSDrive

[DayOfWeek]::Monday

[string]$variable = 'Hello world'
Get-Variable variable | ForEach-Object Attributes

New-Variable -Name var -Value 1 -Option Constant
[System.Reflection.Metadata.Constant]$var2 = 2

Get-ChildItem variable:
Test-Path variable:\VerbosePreference

$left = 1..10000 | ForEach-Object {
    [PSCustomObject]@{
        UserID  = "User$_"
        Country = "UK"
    }
    }
$right = 6400..20000 | ForEach-Object {
    [PSCustomObject]@{
        UserID = "User$_"
        City   = "Manchester"
    }
}

$rightLookup = @{}
$right | ForEach-Object {
$rightLookup[$_.UserID] = $_
}
$left |
Where-Object { $rightLookup.Contains($_.UserID) } |
ForEach-Object {
$_.City = $rightLookup[$_.UserID].City
$_
}

$properties = @(
'FullName'
'Length'
)
$item = Get-Item (Get-Process -Id $PID).Path
$customObject = [Ordered]@{}
$properties | ForEach-Object {
$customObject.$_ = $item.$_
}
[PSCustomObject]$customObject

[System.AppDomain]::CurrentDomain.GetAssemblies()
[System.Management.Automation.PSCredential].Assembly
[System.Management.Automation.PSObject].Assembly

[System.AppDomain].GetType()

[System.IO.File].Namespace

[PowerShell].Assembly

[ADSI]"WinNT://$env:COMPUTERNAME"

[DateTime] | Get-Member -MemberType Method -Static

[Array] | Get-Member -MemberType Method -Static

[string]$variable = 'value'
$typeConverter = (Get-Variable variable).Attributes[0]
$typeConverterType = $typeConverter.GetType()
$targetTypeProperty = $typeConverterType.GetProperty('TargetType',[System.Reflection.BindingFlags]'Instance,NonPublic')
$targetTypeProperty.GetValue($typeConverter)

Find-Type -Namespace System.Management.Automation | Find-Member -GenericParameter System.Object

enum MyEnum {
    First = 1
    Second = 2
    Third = 3
}

enum MyEnum2 : ulong {
    First = 0
    Last = 18446744073709551615
    }

[int][MyEnum]::First
[ulong][MyEnum2]::Last

[MyEnum]::First -as [MyEnum].GetEnumUnderlyingType()

[MyEnum]::First.value__

New-Object MyClass
[MyClass]::new()
# Do not change any default property values
[MyClass]@{}
# Or set a new value for the Value property
[MyClass]@{ Value = 'New value' }

$customObject = [PSCustomObject]@{ Value = 'New value' }
[MyClass]$customObject

[MyClass]::new() | Get-Member get_*, set_* -Force

class MyClass {
    [string] $Value
    MyClass() {
        $this.Value = 'Hello world'
    }
    MyClass(
        [string] $Argument
    ) {
        $culture = Get-Culture
        $this.Value = $culture.TextInfo.ToTitleCase(
            $Argument
        )
    }
}
[MyClass]::new('test')

class MyClass2 {
    [string] $Value = 'Hello world'
    [string] ToString() {
        return '{0} on {1}' -f @(
            $this.Value
    (Get-Date).ToShortDateString()
        )
    }
    [string] ToString(
        [string] $dateFormat
    ) {
        return '{0} on {1}' -f @(
            $this.Value
            Get-Date -Format $dateformat
        )
    }
}
[MyClass2]::new().ToString()

$output = 1..5 | ForEach-Object -Parallel { $_ }

Get-Process | ForEach-Object -MemberName Path

Get-Service | Where-Object -FilterScript {
    $_.StartType -eq 'Manual' -and
    $_.Status -eq 'Running'
    }

(Get-Process | Select-Object -First 1).GetType()

 (Get-Process | Select-Object -Property Path, Company -First 1).GetType()

$p = Get-Process | Select-Object -First 5 -ExpandProperty Name
$p2 = Get-Process | Select-Object -First 5 -Property Name

Get-ChildItem $env:SYSTEMROOT\*.dll |
Select-Object FullName, Length -ExpandProperty VersionInfo |
Format-List *

$computerInfo = Get-CimInstance Win32_ComputerSystem |
Select-Object -Property @(
@{n='ComputerName';e={ $_.Name }}
'DnsHostName'
@{n='OSInfo';e={ Get-CimInstance Win32_OperatingSystem }}
) | 
Select-Object * -ExpandProperty OSInfo |
Select-Object -Property @(
'ComputerName'
'DnsHostName'
@{n='OperatingSystem';e='Caption'}
'SystemDirectory'
)

1, 1, 1, 3, 5, 2, 2, 4 | Select-Object -Unique

Get-Process -Id $PID | Get-Member -MemberType PropertySet

Get-Process -Id $PID | Select-Object -Property PSConfiguration

$process = Get-Process -Id $PID

Get-ChildItem C:\Windows\System32 |
Sort-Object LastWriteTime, Name

Get-ChildItem C:\Windows\Assembly -Filter *.dll -Recurse |
Group-Object Name

Get-ChildItem C:\Windows\Assembly -Filter *.dll -File -Recurse |
Group-Object Name -NoElement |
Where-Object Count -gt 1 |
Sort-Object Count, Name -Descending |
Select-Object Name, Count -First 5

Get-ChildItem C:\Windows\Assembly -Filter *.dll -Recurse |
Group-Object Name, Length -NoElement |
Where-Object Count -gt 1 |
Sort-Object Name -Descending |
Select-Object Name, Count -First 5

$hashtable = @(
[IPAddress]'10.0.0.1'
[IPAddress]'10.0.0.2'
[IPAddress]'10.0.0.1'
) | Group-Object -AsHashtable -AsString

1, 5, 9, 79 | Measure-Object -Sum

1, 5, 9, 79 | Measure-Object -Average -Maximum -Minimum -Sum

Get-Process | Measure-Object WorkingSet -Average

Get-Content C:\Windows\WindowsUpdate.log |
Measure-Object -Line -Word -Character

1..20 | ForEach-Object {
    if ($_ % 2 -eq 0) {
    $foregroundColor = 'Cyan'
    } else {
    $foregroundColor = 'White'
    }
    Write-Host $_ -ForegroundColor $foregroundColor
    }

$i = 0
($i++) # Post-increment
($i--) # Post-decrement

$i = 0
(++$i) # Pre-increment
(--$i) # Pre-decrement

$array = 1..15
$i = 0
while ($i -lt $array.Count) {
    # $i will increment after this statement has completed.
    Write-Host $array[$i++] -ForegroundColor $i
}

$array = 1..5
$i = 0
while ($i -lt $array.Count - 1) {
    # $i is incremented before use, 2 will be the first printed.
    Write-Host $array[++$i]
}

Invoke-ScriptAnalyzer -Path .\*.ps1