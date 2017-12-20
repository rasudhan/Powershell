<#
 # Program:     Gets AD User account activation status
 # File:        HW09B1-Get-UserActivationStatus.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Gets Active Directory User(s) account activation status.
 #  
 # Date:        2017 Apr 15
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Gets Active Directory (AD) user(s) account activation status.
.DESCRIPTION
Gets all the specified Active Directory (AD) user(s) activation status.
If filter is not specified, it obtains all users information.
If filter is specified, it obtains user(s) that match the specification.
Server and Credential may be specified.
Default server is 10.6.20.48.
Default Credential is provided by a call to Get-Credential.
The output of this script is a PSCustom object having SAMAccountName,DisplayName and Enabled properties.
.PARAMETER pServer
Specified the AD server to query.
Default is 10.6.20.48.
.PARAMETER pCredential
Specified the credentials that allow you to access the server's AD.
Default is to call Get-Credential and obtain the credential interactively.
.PARAMETER pFilter
Specifies which users should be obtained.
Uses same format as -Filter parameter to Get-ADUser Cmdlet.
.EXAMPLE
HW09B1-Get-UserActivationStatus.ps1 -pServer $sv -pCredential $cr
Lists SAMAccountName, real name, and activation status for all AD Users.
.EXAMPLE
HW09B1-Get-UserActivationStatus.ps1 -pServer $sv -pCredential $cr -pFilter { Name -Like "HW09*" }
Lists SAMAccountName, real name, and activation status for AD Users whose names begin with HW09.
 #>

[CmdletBinding()]
param(
    [Parameter (
        Mandatory=$false
        , ValueFromPipeline=$False
        )]
    [string] $pServer = "10.6.20.48"

    ,[Parameter (
        Mandatory=$false
        , ValueFromPipeline=$False
        )]
    [System.Management.Automation.PSCredential] $pCredential = (Get-Credential)

    ,[Parameter (
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
    [string] $pFilter = 'Name -Like "*"'

    ) # param()

BEGIN {
    
    # BEGIN block runs once, before the body of the cmd/function/script runs.
    Write-Verbose "BEGIN running."
    
 
    
    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) running."

    Write-Verbose "  pServer:  '$($pServer)'."
    Write-Verbose "  pAccount: '$($pCredential.UserName)'."
    Write-Verbose "  pFilter:  '$($pFilter)'"

    Write-Verbose "BEGIN finished."
    
    } # BEGIN

    
PROCESS {

    Write-Verbose "PROCESS running."

    try {
    $users = Get-ADUser `
        -Server $pServer `
        -Credential $pCredential `
        -Filter $pFilter `
        -Properties `
            SAMAccountName,`
            DisplayName,`
            Enabled
    
    # gets fields in specified order:
    $users | Select `
            SAMAccountName,`
            DisplayName,`
            Enabled
    }
    catch {
    Write-Error "Incorrect Filter Specified!"
    break
    }
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END