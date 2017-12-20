   <#
 # Program:     Disables AD User account(s)
 # File:        HW09B3-Disable-Users.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Disables Active Directory User(s) account(s).
 #  
 # Date:        2017 Apr 15
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Disables Active Directory (AD) user(s) account(s).
.DESCRIPTION
Disables all the specified Active Directory (AD) user(s) account(s).
If filter is specified, it enables user(s) account(s) that match the specification.
Server and Credential may be specified.
Default server is 10.6.20.48.
Default Credential is provided by a call to Get-Credential.
The output of this script is user account names.
.PARAMETER pServer
Specified the AD server to query.
Default is 10.6.20.48.
.PARAMETER pCredential
Specified the credentials that allow you to access the server's AD.
Default is to call Get-Credential and obtain the credential interactively.
.PARAMETER pFilter
Specifies which users should be activated.
Uses same format as -Filter parameter to Get-ADUser Cmdlet.
.PARAMETER pAccountName
Specifies the users account name to be activated.
The account name is the SAMAccountName.
Uses same format as -Identity parameter to Get-ADUser Cmdlet.
.PARAMETER pConfirm
Specifies whether confirmation is required or not. 
Default value is True, that confirmation is required.
.EXAMPLE
(HW09A1-Get-User.ps1 -pServer $sv -pCredential $cr -pFilter { Name -Like "HW09*" }).SAMAccountName | HW09B3-Disable-User.ps1 -pConfirm:$False -pServer $sv -pCredential $cr
Disables all AD Users whose account names start with “HW09”
.EXAMPLE
HW09B3-Disable-User.ps1 -pServer $sv -pCredential $cr -pFilter { Name -Like "HW09*" }
Disables all AD Users whose SAMAccountNames begin with HW09.
 #>
    [CmdletBinding(
    DefaultParameterSetName="One"
    )] 
param(
    [Parameter (
        ParameterSetName="One",
        Mandatory=$false
        , ValueFromPipeline=$False
        )]
        [Parameter (
        ParameterSetName="Two",
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
    [string] $pServer = "10.6.20.48"

    ,[Parameter (
        ParameterSetName="One",
        Mandatory=$false
        , ValueFromPipeline=$False
        )]
        [Parameter (
        ParameterSetName="Two",
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
    [System.Management.Automation.PSCredential] $pCredential = (Get-Credential)


    ,[Parameter (
        ParameterSetName="One",
        Mandatory=$True
        , ValueFromPipeline=$True
        )]
    [String[]] $pAccountName

    ,[Parameter (
        ParameterSetName="Two",
        Mandatory=$True
        , ValueFromPipeline=$False
        )]
    [string] $pFilter = ''

    ,[Parameter (
        ParameterSetName="One",
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
     [Parameter (
        ParameterSetName="Two",
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
    [System.Management.Automation.SwitchParameter] $pConfirm = $True


    ) # param()

BEGIN {
    
    # BEGIN block runs once, before the body of the cmd/function/script runs.
    Write-Verbose "BEGIN running."
    
 
    
    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) running."

    Write-Verbose "  pServer:  '$($pServer)'."
    Write-Verbose "  pAccount: '$($pCredential.UserName)'."
    Write-Verbose "  pPath:  '$($pPath)'"

    Write-Verbose "BEGIN finished."
    
    } # BEGIN

    
PROCESS {

    Write-Verbose "PROCESS running."

    switch ($PSCmdlet.ParameterSetName) {

    "One" {

        foreach ($user in $pAccountName) {
           
           try {
          $username=(get-aduser $user -Server $pServer -Credential $pCredential)
          if($username -eq $null) {
            throw "Incorrect Filter Specified/No Users Found!"
            }
          $username | `
           Disable-ADAccount -Server $pServer -Credential $pCredential  -Confirm:$pConfirm -ErrorAction Stop
           $username.samaccountname 
           }#try
           catch {
            if($username -eq $null) {
              Write-Error "The user '$($user)' does not exits!"
            }
            else {
                Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
                Write-Error "Access Denied."
            }
           
           continue
           }#catch
         }#foreach
      }#one

      "Two" {
            [String] $allDelete1="*"
            [String] $allDelete2='name -like "*"'
            if($pFilter.ToLower().Contains($allDelete2) -or $pFilter.CompareTo($allDelete1) -eq 0) {
                Write-Warning "The filter: '$($pFilter)' could potentially Disable all users. We have disabled it for security purposes."
                exit
            }#if
            try {
            $username=(Get-ADUser -Filter $pFilter -Server $pServer -Credential $pCredential)
            if($username -eq $null) {
            throw "Incorrect Filter Specified/No Users Found!"
            }
            Get-ADUser -Filter $pFilter -Server $pServer -Credential $pCredential| `
              Disable-ADAccount -Server $pServer -Credential $pCredential  -Confirm:$pConfirm -ErrorAction Stop
            $username.samaccountname
              }#try
            catch {
           if($username -eq $null) {
            Write-Error "The user does not exist or incorrect filter specified!"
            
            }
            else {
            Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
            Write-Error "Access Denied."
            }
            
            break
            }#catch
      }#two
    }#switch      
    
   
    
    
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END