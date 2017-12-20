<#
 # Program:     Sets password for AD User account(s)
 # File:        HW09C2-Set-Password.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Sets password for Active Directory User(s) account(s).
 #  
 # Date:        2017 Apr 18
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Sets password for AD User account(s).
.DESCRIPTION
Sets the password for Active Directory (AD) user(s) account(s).
If filter is specified, it retrieves user(s) account(s) that match the specification.
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
Specifies which users should be retrieved.
Uses same format as -Filter parameter to Get-ADUser Cmdlet.
.PARAMETER pAccountName
Specifies the users account name to be retrieved.
The account name is the SAMAccountName.
Uses same format as -Identity parameter to Set-ADAccountPassword Cmdlet.
.PARAMETER pPassword
Prompts the user to enter a new password for account(s).
.PARAMETER pMustChangePWAtNextLogon
Specifies whether the user must change the password at next logon.
.PARAMETER pConfirm
Specifies whether confirmation is required or not. 
Default value is True, that confirmation is required.
.EXAMPLE
HW09C2-Set-Password.ps1 -pServer $sv -pCredential $cr -pFilter { Name -Like "HW09_*" } -pPassword $securePassword -pMustChangePWAtNextLogon -pConfirm:$false
Sets (resets) password for all AD Users whose account names start with “HW09_” to the value stored in the SecureString $securePassword. Requires password to be changed at next logon. Does not require confirmation.
.EXAMPLE
HW09C2-Set-Password.ps1 -pServer $sv -pCredential $cr -pAccountName HW09_BrowSa,HW09_SmitSa -pPassword (Read-Host -Prompt "Enter password: " -AsSecureString)
Sets (resets) password for specified user(s) with pAccountName(s) to the value stored in the SecureString $securePassword or provided in the Read-Host interaction.
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
    [System.Security.SecureString] $pPassword= (Read-Host -Prompt "Enter password: " -AsSecureString)

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
    [System.Management.Automation.SwitchParameter] $pMustChangePWAtNextLogon = $True

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

    $pMustChangePWAtNextLogonUsed = $PSBoundParameters.ContainsKey('pMustChangePWAtNextLogon')

     if($pMustChangePWAtNextLogonUsed) {
            if(-not $pMustChangePWAtNextLogon.IsPresent) {
               [Boolean]$pMustChangePWAtNextLogon=$False
            }
            else {
              [Boolean]$pMustChangePWAtNextLogon=$True
            }

       }

    Write-Verbose "BEGIN finished."
    
    } # BEGIN

    
PROCESS {

    Write-Verbose "PROCESS running."

    switch ($PSCmdlet.ParameterSetName) {

    "One" {

        foreach ($user in $pAccountName) {
          
          try {
          $myUser=get-aduser $user -Server $pServer -Credential $pCredential -ErrorAction Stop

          get-aduser $user -Server $pServer -Credential $pCredential | `
           Set-ADAccountPassword -Reset -Server $pServer -Credential $pCredential -NewPassword $pPassword -Confirm:$pConfirm -ErrorAction Stop
           

           Write-Verbose "Account Password Set Successfully for the user '$($user)'"
           
           
           $myUser.samaccountname
           
            }#try
            catch {
            if($myUser -eq $null) {
            Write-Error "The user '$($user)' does not exist."
            continue
            }
            else {
            Write-Warning "The password does not meet the complexity requirements of the domain. Try a different password."
            Write-Error "The password was not set. Try again with a strong and complex password."
            Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
            Write-Error "Access Denied."
            break
            }

            }#catch        
           
            if($pMustChangePWAtNextLogonUsed) {
             try {      
                Write-Verbose "Trying to Set ChangePasswordAtLogon Parameter to $($pMustChangePWAtNextLogon)"
                Set-ADUser -Identity $user -Server $pServer -Credential $pCredential -ChangePasswordAtLogon:$pMustChangePWAtNextLogon -Confirm:$pConfirm -ErrorAction Stop
                Write-Verbose "Trying to Set ChangePasswordAtLogon Parameter - SUCCESS!"
             }
             catch {
             Write-Warning "Password Never Expires is set to be true for user '$($user)'."
             Write-Error "Does not require password to be changed at next logon."
             Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
             Write-Error "Access Denied."
             continue
             }
            }
                   

           }#foreach
      }

      "Two" {
            [String] $allDelete1="*"
            [String] $allDelete2='name -like "*"'
            if($pFilter.ToLower().Contains($allDelete2) -or $pFilter.CompareTo($allDelete1) -eq 0) {
                Write-Warning "The filter: '$($pFilter)' could potentially set password for all users. We have disabled it for security purposes."
                exit
            }#if
            try {
                $myUsers=Get-ADUser -Filter $pFilter -Server $pServer -Credential $pCredential

                if($myUsers -eq $null) {
                throw "No Users exist(Incorrect Filter specified)!"
                }

                Get-ADUser -Filter $pFilter -Server $pServer -Credential $pCredential | `
                Set-ADAccountPassword -Reset -Server $pServer -Credential $pCredential -NewPassword $pPassword -Confirm:$pConfirm -ErrorAction stop
               Write-Verbose "Account Password Set Successfully for the user"
                
                $myUsers.samaccountname

            }#try
            catch {
                if($myUsers -eq $null) {
                    Write-Warning "Incorrect Filter Specified!"
                    Write-Error "No User(s) Found. Try a different filter."
                }#if
                else {
                    Write-Warning "The password does not meet the complexity requirements of the domain. Try a different password."
                    Write-Error "The password was not set. Try again with a strong and complex password."
                    Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
                    Write-Error "Access Denied."
                }#else
                break
            }#catch

            if($pMustChangePWAtNextLogonUsed) {
                try {
                foreach($user in $myUsers) {
                     Write-Verbose "Trying to Set ChangePasswordAtLogon Parameter to $($pMustChangePWAtNextLogon)"
                    Set-ADUser -Identity $user -Server $pServer -Credential $pCredential -ChangePasswordAtLogon:$pMustChangePWAtNextLogon -Confirm:$pConfirm -ErrorAction Stop 
                    Write-Verbose "Trying to Set ChangePasswordAtLogon Parameter - SUCCESS!"
                 }
                 }
                 catch {
                 Write-Warning "Password Never Expires is set to be true for user '$($user)'."
                 Write-Error "Does not required password to be changed at next logon."
                 Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
                Write-Error "Access Denied."
                 continue
                 }
             }
      }   
    
   
    }#Switch
    
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END