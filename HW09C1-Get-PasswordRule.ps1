<#
 # Program:     Gets password rules for AD User account(s)
 # File:        HW09C1-Get-PasswordRule.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Gets password rules for Active Directory User(s) account(s).
 #  
 # Date:        2017 Apr 15
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Gets password rules for AD User account(s).
.DESCRIPTION
Gets all the password specific rules for Active Directory (AD) user(s) account(s).
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
Uses same format as -Identity parameter to Get-ADUser Cmdlet.
.EXAMPLE
HW09C1-Get-PasswordRule.ps1 -pServer $sv -pCredential $cr -pFilter { Name -Like "HW09*" }
Displays all AD Users (Password Rules) whose account names and password rules start with “HW09”
.EXAMPLE
$results = HW09A1-Get-User.ps1 -pserver 10.5.20.48 -pCredential (Get-Credential) -pFilter *
$results.samaccountname | HW09C1-Get-PasswordRule.ps1 -pCredential $cr
Lists default password rule information for all users that had been retrieved into $results.
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
          $myUsers=get-aduser $user -Server $pServer -Credential $pCredential -ErrorAction Stop

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
            Write-Error "The user '$($user)' does not exist."
            continue

            }#catch        
                    
           }
      }

      "Two" {
            try {
            $myUsers=Get-ADUser -Filter $pFilter -Server $pServer -Credential $pCredential
            if($myUsers -eq $null) {
            throw "No Users exist(Incorrect Filter specified)!"
            }

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
                New-Object -TypeName PSObject -Prop $properties; 
            $userObject | select SAMAccountName,DisplayName,MustChangePWAtNextLogon,CanChangePW,PWNeverExpires 

           }#foreach


              }#try
              catch {
                Write-Warning "Incorrect Filter Specified!"
                Write-Error "No User(s) Found. Try a different filter."
                break
              }#catch

      }
    }   
    
   
    
    
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END