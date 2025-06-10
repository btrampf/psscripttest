# ==============================================================================
# Filename: Search_ACM_Public_DNS.ps1
# Version:  0.1.0| Updated: 2025-05-29
# Author:   Brandon Trampf
# ==============================================================================

#Requires -Modules AWS.Tools.Common,AWS.Tools.CertificateManager

<# =============================================================================
.DESCRIPTION
    Search the AWS API for Certificate Manager (ACM) certificates and identify public DNS records.
.NOTES
    Version History: (see commit history)
    General Notes:
============================================================================= #>

# UPDATE PROFILES
Set-AwsSsoCredential -Account $ACCOUNTS

# SET AWS REGIONS
$regions = @('us-west-2', 'us-east-1')

# GET ACM CERTIFICATE LIST IN ALL ACCOUNTS AND REGIONS
$certs = foreach ($account in $ACCOUNTS) {
    foreach ($region in $regions) {
        Get-ACMCertificateList -ProfileName $account.profile -Region $region -Includes_KeyType 'RSA_4096','RSA_2048' # | Select-Object DomainName, SubjectAlternativeNameSummaries, Type
    }
}

# CHECK FOR PUBLIC DNS RECORDS
$records = $certs | ForEach-Object {
    if ($_.DomainName -notlike '*.info') {
        [PSCustomObject]@{
            Domain = $_.DomainName
            SANs   = $_.SubjectAlternativeNameSummaries -join ', '
        }
    }
}

$records | Format-Table -AutoSize
