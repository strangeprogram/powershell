<#
    .SYNOPSIS
    This script creates Active Directory users from a list in a text file.

    .DESCRIPTION
    Reads usernames from a text file, each on a new line, and creates Active Directory users with initial passwords set to "Buffalo" followed by the current year. The password is set to expire according to the domain policy. Fields have been set to REDACTED for security purposes and can be edited. UserParams can be added as needed as this provides a skeleton

    .NOTES
    Version:        1.0
    Author:         strangeprogram
    Creation Date:  04/14/21
    Purpose/Change: Initial script development was made to automate user creation for your organization.

    .EXAMPLE
    .\CreateADUsers.ps1
#>

# Import Active Directory Module
Import-Module ActiveDirectory

# Path to the text file containing the usernames
$textFilePath = "C:\path\to\your\textfile.txt"

# Read each line as a username from the text file
$usernames = Get-Content $textFilePath

# The current year
$currentYear = (Get-Date).Year

# The password to be set for each user
$password = "Buffalo" + $currentYear

# Convert the password to a SecureString
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force

# Loop through each username and create the user in Active Directory
foreach ($username in $usernames) {
    # Check if user already exists
    $userExists = Get-ADUser -Filter "SamAccountName -eq '$username'" -Server "REDACTED" -ErrorAction SilentlyContinue
    if ($userExists) {
        Write-Output "User $username already exists in AD."
    } else {
        # User attributes - adjust as necessary
        $userParams = @{
            SamAccountName = $username
            UserPrincipalName = "$username@REDACTED"
            Name = $username
            GivenName = $username
            Surname = $username
            Enabled = $true
            AccountPassword = $securePassword
            ChangePasswordAtLogon = $true # Enforce the password change at next logon
            PasswordNeverExpires = $false # Password will expire according to domain policy
            Path = "OU=Users,DC=REDACTED,DC=com" # Specify the correct OU path
            Server = "REDACTED" # Specify the domain controller
        }

        # Create the new user
        try {
            New-ADUser @userParams
            Write-Output "User $username created successfully with a password that will expire according to domain policy."
        } catch {
            Write-Error "An error occurred creating user $username: $_"
        }
    }
}
