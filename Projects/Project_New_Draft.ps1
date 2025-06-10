#Goal:Getting Loggroup retention policies, looking for differences

#Authenticate with AWS
Set-AwsSsoCredential -Account $ACCOUNTS

<# Prep Work
Get-Command -Module AWS.Tools.CloudWatchlogs -verb Get -Noun *group*

$logs = Get-CWLLogGroup -ProfileName esripsfedramp -Region us-east-1

$logs[0] | Select-Object -Property * #>

$east1 = foreach ($account in $ACCOUNTS.profile) {
    Get-CWLLogGroup -ProfileName $account -Region us-east-1 | Select-Object -Property ARN,RetentionInDays
}

$accnum1 = foreach ($e in $east1) {
    ($e.arn).split(':')[4]
}

$eastlogs = [PSCustomObject][ordered]@{
        'Accounts' = @($accnum1)
        'RetentioninDays' = @($east1.RetentionInDays)
        'ARN' = $east1.Arn
    }

$eastlogs | Export-Excel -Path .\Powershell\Projects\retention_east1.xlsx -NoNumberConversion Accounts


$west2 = foreach ($account in $ACCOUNTS.profile) {
    Get-CWLLogGroup -ProfileName $account -Region us-west-2 | Select-Object -Property ARN,RetentionInDays
}

$accnum2 = foreach ($w in $west2) {
    ($w.arn).split(':')[4]
}

$westlogs = [PSCustomObject][ordered]@{
    'Accounts'        = @($accnum2)
    'RetentioninDays' = @($west2.RetentionInDays)
    'ARN'             = $west2.Arn
}


$westlogs | Export-Excel -Path .\Powershell\Projects\retention_west2.xlsx -NoNumberConversion Accounts
