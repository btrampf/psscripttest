<# 
$date = Get-Date  -UFormat "%m_%d_%y %I_%M"
Get-ChildItem .\ | ConvertTo-Json | Out-File .\"Logfile_$Date".json 
#>
$date = Get-Date  -UFormat "%m_%d_%y %I_%M"
$project = 'C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Projects'
$file = 'Current_Files.json'
$newfile = "File_Changes_$date.json"

Get-ChildItem -Recurse -Path $project | ConvertTo-Json | Out-File $project\$file
$oldfiles = Get-Content -Path $project\$file | ConvertFrom-Json

if (condition) {
    <# Action to perform if the condition is true #>
}

$oldfiles = Get-Content -Path $project\$file | ConvertFrom-Json
$newfiles = Get-Content -Path $project\$file2 | ConvertFrom-Json

$diffobj = Compare-Object -ReferenceObject $oldfiles -DifferenceObject $newfiles
$diffobj.InputObject | Select-Object -Property *

$diffjson = Compare-Object (Get-Content -Path $project\$file) -DifferenceObject (Get-Content -Path $project\$file2)
$diffjson

Get-ChildItem -Recurse -Path $project | ConvertTo-Json | Out-File $project\$file2


Get-ChildItem -Recurse -Path $project | ConvertTo-Json | Out-File $project\$file
$oldfiles = Get-Content -Path $project\$file | ConvertFrom-Json
$oldfiles | Select-Object -Property Name | Format-table


Get-ChildItem -Recurse -Path $project | ConvertTo-Json | Out-File $project\$file2
$newfiles = Get-Content -Path $project\$file2 | ConvertFrom-Json
$newfiles | Select-Object -Property Name | Format-table

$diff = Compare-Object (Get-Content -Path $project\$file) -DifferenceObject (Get-Content -Path $project\$file2)

$diff = Compare-Object -ReferenceObject $oldfiles -DifferenceObject $newfiles
$diff | ConvertTo-Json | gm



$test = Get-Content -Path $project\$file
$test2 = Get-ChildItem -Recurse -Path $project | ConvertTo-Json

$test -like $test2

help get-filehash

foreach ($i in $items) {
    $changes = @{ Data = @() }
}
if ( $i -notin $data ) {
    $changes.data += $i
}
$newobj = [pscustomobject] $changes

$newobj.Data


if (($items | select-Object -Property name | Convertto-csv) -match (Get-Content -Path $file)) {
    $items | Export-Csv -Path $project\$newfile
}

$change = Get-ChildItem -Recurse -Path $project | Select-Object -Property Name 
$change | Export-Csv -Path $project\$newfile

$oldobj = foreach ($item in $items) {
    [PSCustomObject] @{
        Name = $item.name
    }
}

$CustObject1 | Where-Object { $_.name -notin $CustObject2.id }
