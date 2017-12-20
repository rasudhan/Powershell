<#
 # Program:     Sets password rules for AD User account(s)
 # File:        HW09C3-Set-PasswordRule.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Sets password rules for Active Directory User(s) account(s).
 #  
 # Date:        2017 Apr 18
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Sets password rules for AD User account(s).
.DESCRIPTION
Sets the password rules for Active Directory (AD) user(s) account(s).
If filter is specified, it retrieves user(s) account(s) that match the specification.
Server and Credential may be specified.
Default server is 10.6.20.48.
Default Credential is provided by a call to Get-Credential.
The output of this script is custom PSObjects containing password specific rules.
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
Uses same format as -Identity parameter to Set-ADUser Cmdlet.
.PARAMETER pPwNeverExpires
Specifies the user(s) password never expires.
.PARAMETER pCanChangePW
Specifies the user is allowed to change password for account(s).
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
    [System.Management.Automation.SwitchParameter] $pCanChangePW = $True #default value when creating new user


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
    [System.Management.Automation.SwitchParameter] $pPwNeverExpires = $false #default value when creating new user

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
    [System.Management.Automation.SwitchParameter] $pMustChangePWAtNextLogon = $false  #default value when creating new user

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
   
   $pCanChangePWUsed = $PSBoundParameters.ContainsKey('pCanChangePW')
   $pPwNeverExpiresUsed = $PSBoundParameters.ContainsKey('pPwNeverExpires')
   $pMustChangePWAtNextLogonUsed = $PSBoundParameters.ContainsKey('pMustChangePWAtNextLogon')

   


    Write-Verbose "pCanChangePWUsed             = '$($pCanChangePWUsed)'"
    Write-Verbose "pPwNeverExpiresUsed          = '$($pPwNeverExpiresUsed)'"
    Write-Verbose "pMustChangePWAtNextLogonUsed = '$($pMustChangePWAtNextLogonUsed)'"
    
    if($pCanChangePWUsed -or $pPwNeverExpiresUsed -or $pMustChangePWAtNextLogonUsed) {
       
        if(-not $pCanChangePW.IsPresent) {
            [Boolean]$pCanChangePW=$False 
            [Boolean]$pCannotChangePW=-not $pCanChangePW #Since actual parameter is CannotChangePW
            Write-Verbose "CanChangePW = $($pCanChangePW) Hence CannotChangePW=$($pCannotChangePW)"
        }
        else {
            [Boolean]$pCanChangePW=$True
            [Boolean]$pCannotChangePW=-not $pCanChangePW #Since actual parameter is CannotChangePW
            Write-Verbose "CanChangePW = $($pCanChangePW) Hence CannotChangePW=$($pCannotChangePW)"

        }

       if($pPwNeverExpiresUsed -and $pPwNeverExpires.IsPresent) {
            [Boolean]$pPwNeverExpires=$True
       }
       else {
           [Boolean]$pPwNeverExpires=$False
       }

       if($pMustChangePWAtNextLogon -and ( $pMustChangePWAtNextLogon.IsPresent)) {
            [Boolean]$pMustChangePWAtNextLogon=$True
       }
       else {
            [Boolean]$pMustChangePWAtNextLogon=$False
       }

     }
       else {
       Write-Warning "No Password Rules specified"
       Write-Error "Atleast One Parameter must be used to specify password rule."
       exit
      
       }

        if($pMustChangePWAtNextLogon -and $pPwNeverExpires) {
            Write-Warning "A conflict has occurred. The PasswordNeverExpires/MustChangePassword is set to be True for the user '$($user)'. "
            Write-Error "The password rules may not be set as expected. "
            exit
        }
        elseif($pMustChangePWAtNextLogon -and $pCannotChangePW) {
             Write-Warning "A conflict has occurred. The MustChangePassword/UserCannotChangePassword is set to be True for the user '$($user)'. "
             Write-Error "The password rules may not be set as expected. "
             exit
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

         
              Set-ADUser  -Identity $user `
                          -Server $pServer `
                          -Credential $pCredential `
                          -CannotChangePassword $pCannotChangePW `
                          -ChangePasswordAtLogon $pMustChangePWAtNextLogon `
                          -PasswordNeverExpires $pPwNeverExpires `
                          -Confirm:$pConfirm `
                          -ErrorAction Stop
                        
            

            $userData=get-aduser $user -Server $pServer -Credential $pCredential -Properties *| `
                 select SAMAccountName, `
                        DisplayName, `
                        PasswordExpired, `
                        CannotChangePassword, `
                        PasswordNeverExpires
           
           $userData | ForEach-Object {

           $userSAM=($_.samaccountname);
           $userName=($_.displayname);
           $userMustChangePWAtNextLogon=($_.passwordexpired);
           $userCanChangePW=(-not $_.CannotChangePassword);
           $userPWNeverExpires=($_.PasswordNeverExpires);
           $properties = `
                @{ `
                    'SAMAccountName'         =$userSAM; 
                    'DisplayName'            =$userName; 
                    'MustChangePWAtNextLogon'=$userMustChangePWAtNextLogon; 
                    'CanChangePW'            =$userCanChangePW;
                    'PWNeverExpires'         =$userPWNeverExpires;
                    }; 
            $userObject = `
                New-Object -TypeName PSObject -Prop $properties; 
            $userObject | select SAMAccountName,DisplayName,MustChangePWAtNextLogon,CanChangePW,PWNeverExpires 

           }#foreach
           
           
            }#try
            catch {
            if($myUser -eq $null) {
            Write-Error "The user '$($user)' does not exist."
            continue
            }
            else {
           # Write-Warning "A conflict has occurred. The PasswordNeverExpires/UserCannotChangePassword is set to be True for the user '$($user)'. "
           # Write-Error "The password rules were not set. "
            Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
            Write-Error "Access Denied."
            break
            }

            }#catch        
                   

           }#foreach
      }

      "Two" {
            [String] $allDelete1="*"
            [String] $allDelete2='name -like "*"'
            if($pFilter.ToLower().Contains($allDelete2) -or $pFilter.CompareTo($allDelete1) -eq 0) {
                Write-Warning "The filter: '$($pFilter)' could potentially set password rules for all users. We have disabled it for security purposes."
                exit
            }#if
            try {
                $myUsers=Get-ADUser -Filter $pFilter -Server $pServer -Credential $pCredential

                if($myUsers -eq $null) {
                throw "No Users exist(Incorrect Filter specified)!"
                }

               
               $myUsers | `
                Set-ADUser  `
                          -Server $pServer `
                          -Credential $pCredential `
                          -CannotChangePassword $pCannotChangePW `
                          -ChangePasswordAtLogon $pMustChangePWAtNextLogon `
                          -PasswordNeverExpires $pPwNeverExpires `
                          -Confirm:$pConfirm `
                          -ErrorAction Stop
                        


                  $userData=Get-ADUser -Filter $pFilter -Properties * -Server $pServer -Credential $pCredential| `
             select SAMAccountName, `
                    DisplayName, `
                    PasswordExpired, `
                    CannotChangePassword, `
                    PasswordNeverExpires -ErrorAction Stop

               $userData | ForEach-Object {

           $userSAM=($_.samaccountname);
           $userName=($_.displayname);
           $userMustChangePWAtNextLogon=($_.passwordexpired);
           $userCanChangePW=(-not $_.CannotChangePassword);
           $userPWNeverExpires=($_.PasswordNeverExpires);
           $properties = `
                @{ `
                    'SAMAccountName'         =$userSAM; 
                    'DisplayName'            =$userName; 
                    'MustChangePWAtNextLogon'=$userMustChangePWAtNextLogon; 
                    'CanChangePW'            =$userCanChangePW;
                    'PWNeverExpires'         =$userPWNeverExpires;
                    }; 
            $userObject = `
                New-Object -TypeName PSObject -Property $properties; 
            $userObject | select SAMAccountName,DisplayName,MustChangePWAtNextLogon,CanChangePW,PWNeverExpires 

           }#foreach
                
                

            }#try
            catch {
                if($myUsers -eq $null) {
                    Write-Warning "Incorrect Filter Specified!"
                    Write-Error "No User(s) Found. Try a different filter."
                }#if
                else {
                  # Write-Warning "A conflict has occurred. The PasswordNeverExpires/UserCannotChangePassword is set to be True for the user '$($user.samaccountname)'. "
                 #  Write-Error "The password rules were not set. "
                   Write-Warning "If you were trying to perform operations on accounts other than those in OU=HW09OU_RameAn, you do not have sufficient access permissions."
                    Write-Error "Access Denied."
                }#else
                break
            }#catch
            
      }   
    
   
    }#Switch
    
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END