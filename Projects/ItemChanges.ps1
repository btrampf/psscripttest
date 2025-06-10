# $datetime = Get-Date  -UFormat "%m%d%y_%I%M"
# $newchange = "FileChanges.csv"
$exchange = "FileChanges.xlsx"
$project = 'C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Projects'
$logs = 'C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Logs'
$currfiles = 'Current_Files.csv'
$hashfiles = 'Hash_Files.csv'

<# Before First Run: Must establish current file list (there must be starting file)
$curritem | Export-Csv -Path $logs\$currfiles #>

#get a list of current files in all folders and subfolders
$curritem = Get-ChildItem -Path $project -Recurse

#create a variable that has a list of current files in csv
$items = join-path -Path $logs -ChildPath $currfiles

#Test to see if the csv exists and if it does, import it
if (Test-Path -Path $items) {
    $previtem = Import-csv -Path $items
}

<# Before First Run: Must establish current hash values (there must be start starting file) 
$currhash | Export-Csv -Path $logs\$hashfiles #>

#get the hash values of all current files in all folders and subfolders
$currhash = $curritem | Where-Object -Property Attributes -ne Directory | Get-FileHash

#create a variable that has current hash values in csv
$hash = join-path -Path $logs -ChildPath $hashfiles

#Test to see if the csv exists and if it does, import it
if (Test-Path -Path $hash) {
    $prevhash = Import-csv -Path $hash
}

#item compare-object properties
$itemprop = @('Name')

#item compare-object cmdlet parameter hashtable
$itemcomp = @{
    ReferenceObject  = $previtem
    DifferenceObject = $curritem
    Property         = $itemprop
    SyncWindow       = 1000
}
#hash compare-object properties
$hashprop = @('Hash', 'Path')

#hash compare-object cmdlet parameter hashtable
$hashcomp = @{
    ReferenceObject  = $prevhash
    DifferenceObject = $currhash
    Property         = $hashprop
    SyncWindow       = 1000
}
#compare previous items to current items
$itemresults = Compare-Object @itemcomp | Sort-Object -Property $itemprop

#compare previous hash values to current hash values
$hashresults = Compare-Object @hashcomp | Sort-Object -Property $hashprop

#reestablish current item list
$curritem | Export-csv -Path $items

#reestablish current hash values
$currhash | Export-csv -Path $hash

#removed files
$remfiles = $itemresults | Where-Object -Property SideIndicator -EQ '<=' | Select-Object -Property Name
#new files
$newfiles = $itemresults | Where-Object -Property SideIndicator -EQ '=>' | Select-Object -Property Name
#hash/file changes - ($hashresults | Where-Object -Property SideIndicator -EQ '=>').path.split('\')[-1]
$filechange = $hashresults | Where-Object -Property SideIndicator -EQ '=>' | Select-Object -Property Path | Split-Path -Leaf

#if any files were removed, added, or modified then run
if (($remfiles.count -ne 0) -or ($newfiles.count -ne 0) -or ($filechange.count -ne 0)) {
    
    #create text formating for appended data callouts
    $text1 = New-ConditionalText -Text Removed -ConditionalTextColor Red -BackgroundColor White
    $text2 = New-ConditionalText -Text Added -ConditionalTextColor Green -BackgroundColor White
    $text3 = New-ConditionalText -Text Modified -ConditionalTextColor DarkBlue -BackgroundColor White
    #$format1 = Add-ConditionalFormatting -Backgroundcolor LightGray

    #create hashtable for Export-Excel parameters
    $exparam = @{
        Path            = "$logs\$exchange"
        AutoSize        = $true
        BoldTopRow      = $true
        TableName       = 'FileChanges'
        TableStyle      = 'Light8'
        Append          = $true
        ConditionalText = @($text1, $text2, $text3)
    }

    #if any files were removed then run
    if ($remfiles.count -ne 0) {
        #Let user know how many files were removed
        Write-Output -InputObject ('{0} file(s) removed' -f $remfiles.count)

        foreach ($rfile in $remfiles) {
            #Let user know what files were removed
            Write-Output -InputObject ("{0} was removed from $project" -f $rfile.name)
            
            #Removed file properties to export
            $remexp = [PSCustomObject][ordered]@{
                'File Name'   = $rfile.name
                'Change Type' = 'Removed'
                'Date'        = $(Get-Date -Format MM/dd/yyyy)
                'Time'        = $(Get-Date -Format HH:mm)
            }
            #Create custom object and export removed files to logfile
            $remexp | Export-Excel @exparam
        }
    }
    #Let user know no files were removed
    else {
        Write-Output -InputObject "No file(s) were removed"
    }
    #If any files were added then run
    if ($newfiles.count -ne 0) {
        #Let user know how many files were added
        Write-Output -InputObject ('{0} file(s) added' -f $newfiles.count)

        foreach ($nfile in $newfiles) {
            #Let user know what files were added
            Write-Output -InputObject ("{0} was added to $project" -f $nfile.name)

            #New file properties to export
            $newexp = [PSCustomObject][ordered]@{
                'File Name'   = $nfile.name
                'Change Type' = 'Added'
                'Date'        = $(Get-Date -Format MM/dd/yyyy)
                'Time'        = $(Get-Date -Format HH:mm)
            }
            #Create custom object and export files which were added to logfile
            $newexp | Export-Excel @exparam
        }
    }
    #Let user know no files were added
    else {
        Write-Output -InputObject "No file(s) were added"
    }
    #if any files were modified then run
    if ($filechange.count -ne 0) {
        #Let user know how many files were modified
        Write-Output -InputObject ("{0} file(s) modified in $project" -f $filechange.count)
    
        foreach ($fchange in $filechange) {
            #Let user know what files were modified
            Write-Output -InputObject ('{0} file was modified' -f $fchange)

            #File change properties to export
            $changeexp = [PSCustomObject][ordered]@{
                'File Name'   = $fchange
                'Change Type' = 'Modified'
                'Date'        = $(Get-Date -Format MM/dd/yyyy)
                'Time'        = $(Get-Date -Format HH:mm)
            }
            #Create custom object and export file modifications to log file
            $changeexp | Export-Excel @exparam
        }
    }
    #Let user know know no files were modified
    else {
        Write-Output -InputObject "No file(s) were modified"
    }
    #Let user know that files are being written to logfile
    Write-Output -InputObject ('Writing to Logfile - {0}\{1} ' -f $logs, $exchange)
}
#Let user know that no files were removed, added or modified
else {
    Write-Output -InputObject 'There were no file changes'
}