# ==============================================================================
# Filename: Export-AccessReport.ps1
# Version:  0.1.0 | Updated: 2025-06-04
# Author:   Justin Johns
# ==============================================================================

#Requires -Modules SecurityTools, ImportExcel, ActiveDirectory, AWSAutomation, AWS.Tools.S3
#Requires -Modules AWS.Tools.IdentityManagement, AWS.Tools.SimpleNotificationService
#Requires -Modules AWS.Tools.SimpleSystemsManagement, AWS.Tools.SecurityToken

<# =============================================================================
.DESCRIPTION
    This script generates an Excel spreadsheet report Public DNS records 
    from AWS Certificate Manager (ACM) certificates.
.NOTES
    Version History:
    General Notes:
    Create Schedule Task and set to run every 90 days
============================================================================= #>

# CHECK FOR CONFIG FILE PARAM
$tempFolder = 'C:\TEMP\Reports'
if ( !(Test-Path -Path $tempFolder) ) { New-Item -Path $tempFolder -ItemType Directory }

# GET PARAMETER DATA
$inventory = (Get-SSMParameter -Name 'Inventory' -ErrorAction 1).Value | ConvertFrom-Json

# SET EXCEL OPTIONS
$excelParams = @{
    TableStyle = 'Medium2'
    Style      = (New-ExcelStyle -Bold -Range '1:1' -HorizontalAlignment Center)
    Path       = Join-Path -Path $tempFolder -ChildPath ([System.IO.Path]::GetRandomFileName())
}

# LOOP CREDENTIALS AND GET DATA FOR EACH
foreach ( $a in $inventory.Accounts ) {

    # SET STS PARAMS
    $stsParams = @{
        RoleSessionName = 'AssumeRoleReportWriter'
        RoleArn         = 'arn:aws:iam::{0}:role/roleReportWriter' -f $a.Id
    }

    # GET CREDENTIALS FOR REPORT WRITER ROLE
    $creds = New-AWSCredential -Credential (Use-STSRole @stsParams).Credentials

    # INITIATE REQUEST FOR IAM REPORT AND CHECK FOR STATUS CHANGE EVERY 5 SECONDS
    do { $state = (Request-IAMCredentialReport -Credential $creds).State.Value; Start-Sleep -Seconds 5 }
    while ($state -eq 'STARTED')

    # IF THE REPORT STATUS CHANGES TO 'COMPLETE' SET THE REPORT DETAILS TO A VARIABLE
    if ($state -eq 'COMPLETE') { $credReport = Get-IAMCredentialReport -Credential $creds -AsTextArray | ConvertFrom-Csv }
    else { Throw ('Failed to retrieve report with status: {0}' -f $state) }

    foreach ($obj in $credReport) { $iamReport.Add($obj) }
}

# EXPORT DATA TO NEW EXCEL TAB
$iamReport | Export-Excel @excelParams -WorksheetName 'AWS-Users'

# UPLOAD REPORT TO S3
$s3Params = @{
    BucketName = 'emcsreports'
    Key        = 'Security/Access/Reports/{0:yyyy}/{0:yyyy-MM-dd}_AccessReport.xlsx' -f (Get-Date)
    File       = $excelParams['Path']
}
Write-S3Object @s3Params

# SEND NOTIFICATION OF NEW REPORT
$snsParams = @{
    TopicArn = 'arn:aws:sns:us-east-1:{0}:AutomationAlerts' -f (Get-STSCallerIdentity).Account
    Subject  = 'Access Report Uploaded'
    Message  = 'New access report uploaded to bucket {0} in path {1}' -f $s3Params.BucketName, $s3Params['Key']
}
Publish-SNSMessage @snsParams

# CLEAN UP
Remove-Item -Path $tempFolder -Recurse -Force -Confirm:$false