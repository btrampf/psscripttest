#Authenticate with AWS
Set-AwsSsoCredential -Account $ACCOUNTS

#conditional text parameters for export-excel
$text1 = New-ConditionalText -ConditionalType LessThan -Text 90 -ConditionalTextColor Red
$text2 = New-ConditionalText -ConditionalType ContainsBlanks -BackgroundColor Red

#export excel parameters
$exparam = @{
    Path               = "C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Projects\RetentionPolicy.xlsx"
    AutoSize           = $true
    AutoFilter         = $true
    BoldTopRow         = $true
    TableName          = 'LogGroupRetentionPolicies'
    TableStyle         = 'Light8'
    Append             = $true
    ConditionalText    = @($text1, $text2)
    NoNumberConversion = '*'
}

#Get a list of AWS CloudWatch Group for accounts that are in us-west-2 (SOC2)
$socgrps = foreach ($socacc in $ACCOUNTS) {
    Get-CWLLogGroup -ProfileName $socacc.profile -Region us-west-2 | Select-Object -Property ARN, RetentionInDays
}

#take each us-west-2 cloudWatch Group log, build a custom object, and export to excel
foreach ($slog in $socgrps) {
            
    $socobj = @()

    $socobj += [PSCustomObject][ordered]@{
        Accounts        = ($slog.arn).split(':')[4]
        RetentioninDays = $slog.RetentionInDays
        ARN             = $slog.Arn
        ENV             = 'SOC2'
    }

    $socobj | Export-Excel @exparam
}

#Get a list of AWS Logs for accounts that are in us-east-1 (FEDRAMP)
$fedgrps = foreach ($fedacc in $ACCOUNTS) {
    Get-CWLLogGroup -ProfileName $fedacc.profile -Region us-east-1 | Select-Object -Property ARN, RetentionInDays
}

#take each us-east-1 cloudWatch Group log, build a custom object, and export to excel
foreach ($flog in $fedgrps) {
            
    $fedobj = @()

    $fedobj += [PSCustomObject][ordered]@{
        Accounts        = ($flog.arn).split(':')[4]
        RetentioninDays = $flog.RetentionInDays
        ARN             = $flog.Arn
        ENV             = 'FEDRAMP'
    }

    $fedobj | Export-Excel @exparam
}
#Create ExcelPackage Object for further processing
$excelpkg = Open-ExcelPackage -Path "C:\Users\bran8994\Documents\EMCS Security Team\Powershell\Projects\RetentionPolicy.xlsx"

#Create a Worksheet object to pass to processing commands
$sheet = $excelpkg.workbook.Worksheets["Sheet1"]

#Align Center Header Row text
Set-ExcelRange -Worksheet $sheet -Range "A1:D1" -HorizontalAlignment Center

#close the package and apply the changes
Close-ExcelPackage -ExcelPackage $excelpkg


#Set-ExcelColumn -Worksheet $worksheet
#Set-ExcelRow -Worksheet $sheet -Row "1" -HorizontalAlignment Center
#$excelpkg.workbook.Worksheets["Sheet1"].Cells[2,3].Hyperlink = $null


