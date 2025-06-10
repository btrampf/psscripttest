# ==============================================================================
# Filename: AWS_AMI_Search.ps1
# Version:  0.1.0| Updated: 2025-04-08
# Author:   Brandon Trampf
# ==============================================================================

#Requires -Modules AWS.Tools.Common,AWS.Tools.EC2

<# =============================================================================
.DESCRIPTION
    Search the AWS API for our AMI to see if it was updated recently.
.NOTES
    Version History: (see commit history)
    General Notes:
============================================================================= #>

# UPDATE PROFILES
Set-AwsSsoCredential -Account $ACCOUNTS

# SET CREDENTIALS
$awsCreds = @{ ProfileName = 'soc2master'; Region = 'us-west-2' }

# CURRENT AMI
$currami = 'TPM-Windows_Server-2022-English-Full-Base'

# FILTER PARAMETERS
$filter = @(
    @{Name = 'name'; Values = "$currami*" },
    @{Name = 'state'; Values = 'available' },
    @{Name = 'platform'; Values = 'windows' }
)

# GET LATEST AMI DETAILS (FILTERED)
$latimg = Get-EC2Image @awsCreds -Filter $filter

#FORMAT RESULTS
$latimg | Select-Object Name, CreationDate, ImageId, Platform | Sort-Object -Property CreationDate | Format-list
