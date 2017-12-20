<#
 # Program:     Get AD Users
 # File:        HW09A1-Get-User.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Lists all the Active Directory Users.
 #  
 # Date:        2017 Apr 15
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Gets Active Directory (AD) user(s).
.DESCRIPTION
Lists all the specified Active Directory (AD) user(s).
If no filter is specified, it lists all users.
If filter is specified, it lists user(s) that match the specification.
Server and Credential may be specified.
Default server is 10.6.20.48.
Default Credential is provided by a call to Get-Credential.
The output of this script is user account objects.
.PARAMETER pServer
Specified the AD server to query.
Default is 10.6.20.48.
.PARAMETER pCredential
Specified the credentials that allow you to access the server's AD.
Default is to call Get-Credential and obtain the credential interactively.
.PARAMETER pFilter
Specifies which users should be listed.
Uses same format as -Filter parameter to Get-ADUser Cmdlet.
Default is all users.
.EXAMPLE
HW09A1-Get-User.ps1 -pServer 10.6.20.48 -pCredential (Get-Credential)
Lists all information about all AD Users.
.EXAMPLE
HW09A1-Get-User.ps1 -pServer 10.5.20.48 -pCredential (Get-Credential) -pFilter { SAMAccountName -Like "HW09_*" }
Gets only the accounts of the AD users who SAMAccountNames that start with “HW09_”.
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
        -Properties * -ErrorAction Stop
    }
    catch {
    Write-Error "Users not found! Please specify the correct server/credential/filter..."
    break
    }            
    
    $users
  
    
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END