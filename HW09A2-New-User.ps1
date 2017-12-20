<#
 # Program:     Creates AD Users
 # File:        HW09A2-New-User.ps1
 # Author:      Anand Ramesh Kannan
 # Description: Creates Active Directory Users.
 #  
 # Date:        2017 Apr 15
 #                - Created
 #              2017 Apr 18
 #                - Added Help File
 #>

<#
.SYNOPSIS
Creates Active Directory (AD) user(s).
.DESCRIPTION
Creates all the specified Active Directory (AD) user(s).
If no path is specified, it creates user(s) in the default path.
If path is specified, it creates user(s) in the given path.
Server and Credential may be specified.
Default server is 10.6.20.48.
Default Credential is provided by a call to Get-Credential.
The output of this script is SAMAccountNames.
.PARAMETER pServer
Specified the AD server to query.
Default is 10.6.20.48.
.PARAMETER pCredential
Specified the credentials that allow you to access the server's AD.
Default is to call Get-Credential and obtain the credential interactively.
.PARAMETER pPath
Specifies which path the users should be created.
Uses same format as -Path parameter to New-ADUser Cmdlet.
Default is all 'OU=HW09OU_RameAn,OU=CIS620_2017_1,DC=CIS620,DC=TurkDom,DC=Net'.
.PARAMETER pFullName
Specifies the users full name.
Uses same format as -Name parameter to New-ADUser Cmdlet.
.PARAMETER pPrefix
Specifies the prefix for each account name.
.PARAMETER pPassword
Prompts the user to enter a password for accounts to be created.
.EXAMPLE
HW09A2-New-User.ps1 -pServer $sv -pCredential $cr -pFullName "Sally Smith","Jason Jones","Allison Smith Jones" -pPrefix "HW09_" -Verbose
Adds users HW09_smithsa, HW09_joneja, and HW09_joneal, if they do not already exist. 
.EXAMPLE
HW09A2-New-User.ps1 -pServer $sv -pCredential $cr -pFullName "Sally Smith","Jason Jones","Allison Smith Jones" -pPrefix "HW09_" -pPath "OU=HW09OU_0tesT1,DC=c0,DC=CIS620,DC=Net" -Verbose
Adds users HW09_smithsa, HW09_joneja, and HW09_joneal to the “HW09OU_0tesT1” OU, if they do not already exist. Displays “verbose” output.

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
    [string] $pPath = 'OU=HW09OU_RameAn,OU=CIS620_2017_1,DC=CIS620,DC=TurkDom,DC=Net'

    ,[Parameter (
        Mandatory=$True
        , ValueFromPipeline=$True
        )]
    [string[]] $pFullName

    ,[Parameter (
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
    [string] $pPrefix="HW09_"

    ,[Parameter (
        Mandatory=$False
        , ValueFromPipeline=$False
        )]
    [System.Security.SecureString] $pPassword= (Read-Host -Prompt "Enter password: " -AsSecureString)

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

    foreach ($name in $pFullName) {

    $displayName= $name
    $theName=$name.split(" ");

    [String]$givenName=$theName[0];
    [String]$surName=$theName[$theName.Length-1];
    try {
    $theName=$theName[$theName.Length-1].substring(0,4)+$theName[0].substring(0,2); 
    }
    catch {
    write-warning "The name does not have enough characters as expected..."
    }
    $myName = $pPrefix + $theName
    $SAMAccountName = $pPrefix + $theName
    
    
    $newUser=Get-ADUser -Filter "Name -like '$myName'" -ErrorAction Ignore
 
  
    try {
    if($pPath -eq "") {
    Write-Verbose "Without Path"
    New-ADUser -Name $myName `
               -AccountPassword $pPassword `
               -SamAccountName $SAMAccountName `
               -DisplayName $displayName `
               -GivenName $givenName `
               -Surname $surName `
               -ChangePasswordAtLogon:$True `
               -PasswordNeverExpires:$False `
               -Enabled:$True `
               -Server $pServer `
               -Credential $pCredential 
              
               }
       
    else {
    Write-Verbose "With Path"
       New-ADUser -Name $myName `
               -AccountPassword $pPassword `
               -SamAccountName $SAMAccountName `
               -DisplayName $displayName `
               -GivenName $givenName `
               -Surname $surName `
               -ChangePasswordAtLogon:$True `
               -PasswordNeverExpires:$False `
               -Enabled:$True `
               -Path $pPath `
               -Server $pServer `
               -Credential $pCredential 
               Write-Verbose "With Path - SUCCESS!"
    
  
          }     
    }
    catch {
    
        if($newUser -eq $null) {
            Write-Warning "If you had specified a weak password, the account was created but not enabled."
            $newUser=Get-ADUser -Filter "Name -like '$myName'"
            $newUser.samaccountname
        }
        else {
        Write-Error "Could not create user! A user with the name '$($SAMAccountName)' already exists/Specified Path is wrong! `
                     Please try different name/path...."
        }
        continue
    }

    $newUser=Get-ADUser -Server $pServer -Credential $pCredential -Filter "Name -like '$myName'"
    $newUser.samaccountname

    }
   
    
    
    Write-Verbose "PROCESS finished."

    } # PROCESS

END {

    Write-Verbose "END running."

    Write-Verbose "$(Get-Date): $($MyInvocation.MyCommand.Name) finished."

    Write-Verbose "END finished."

    } # END