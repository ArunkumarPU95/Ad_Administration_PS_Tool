Clear-Host

Write-host "
===============================
 AD Account Administration Tool; Author: Arunkumar.Pu@conduent.com
===============================
"-ForegroundColor Cyan

Import-Module ActiveDirectory

$tool = Read-Host "1.AD User Account Creation`n2.AD User Account Bulk Password Reset`n3.AD User Account Change OU`n4.AD Computer Account Change OU`n`nPlease enter your option" 

switch ($tool)
{
    
    '1'
    {
        $DomainName = Get-ADDomain | Select -ExpandProperty NetBIOSName

        $opt = Read-Host "Select the account creation method`n`n1.Create user accounts manually`n2.Create accounts from CSV file`nYour option"

        switch ($opt)
        {
            '1'
            {
                $mirror_id = Read-Host "`nEnter the mirror ID to locate the OU"
                $mirror_ou = Get-ADUser $mirror_id -Properties DistinguishedName | select DistinguishedName
                $mirror_ou = $mirror_ou.DistinguishedName
                $mirror_ou = $mirror_ou.Substring($mirror_ou.IndexOf(",")+1)
                Write-Host `nMirror OU is $mirror_ou  -ForegroundColor Green
           
                Do
                {
                    $FN = Read-Host "`nEnter First Name"
                    $LN = Read-Host "Enter Last Name"
                    $sAN = Read-Host "Enter WinID"
                    $Name = $FN + " " + $LN
                    $DName = $Name
                    $Description = Read-Host 'Enter description'
                    $upn = $sAN + '@' + $DomainName + '.com'
                    $Pass = Read-Host 'Enter Password'
                    $pwd = ConvertTo-SecureString $Pass -AsPlainText -Force
                                
                    New-ADUser -GivenName $FN -Surname $LN -SamAccountName $sAN -Name $Name -DisplayName $Name -Description $Description -UserPrincipalName $upn -Path $mirror_ou -AccountPassword $pwd -Enabled $TRUE
                    Write-Host $Name - $sAN Created Succefully -ForegroundColor Green

                    $Loop = Read-Host "`nDo you want to create another user account [Y/N]"

                } while ($Loop -eq 'Y')
            }

            '2'
            {
                $mirror_id = Read-Host "`nEnter the mirror ID to locate the OU"
                $mirror_ou = Get-ADUser $mirror_id -Properties DistinguishedName | select DistinguishedName
                $mirror_ou = $mirror_ou.DistinguishedName
                $mirror_ou = $mirror_ou.Substring($mirror_ou.IndexOf(",")+1)
                Write-Host `nMirror OU is $mirror_ou  -ForegroundColor Green

                Import-csv "AccountCreation.csv" | ForEach-Object {
            
                    $FN = $_."FirstName"
                    $LN = $_."LastName"
                    $sAN = $_."WINID"
                    $Description = $_."Description"
                    $Pass = $_."Password"

                    $Name = $FN + " " + $LN
                    $DName = $Name            
                    $upn = $sAN + '@' + $DomainName + '.com'            
                    $pwd = ConvertTo-SecureString $Pass -AsPlainText -Force
                                
                    New-ADUser -GivenName $FN -Surname $LN -SamAccountName $sAN -Name $Name -DisplayName $Name -Description $Description -UserPrincipalName $upn -Path $mirror_ou -AccountPassword $pwd -Enabled $TRUE
                    Write-Host $Name - $sAN Created Succefully -ForegroundColor Green
                }
            }
        }

    }

    '2'
    {
        $pswd = Read-Host "Enter the password" # Read the new password

        $newPassword = ConvertTo-SecureString -AsPlainText $pswd -Force

        Import-Csv "PasswordReset.csv" | ForEach-Object {  # Collect the identity of users from CSV file

            $userid = $_."Winid"
    
            try # Error Handling for AD query
            {
                if(get-aduser $userid) # Check the existense of identity in the AD
                {
                    Set-ADAccountPassword -Identity $userid -NewPassword $newPassword -Reset # Reset the AD account password

                    Write-Host " AD Password has been reset for: "$userid # Confirmation message on console
                }
            }

            catch
            {
                Write-Host "AD account not found :" $userid -ForegroundColor Red # Error message on console
            }
 
        }
    }

    '3'
    {
        $mirror_id = Read-Host "`nEnter the mirror ID to locate the OU"
        $mirror_ou = Get-ADUser $mirror_id -Properties DistinguishedName | select DistinguishedName
        $mirror_ou = $mirror_ou.DistinguishedName
        $mirror_ou = $mirror_ou.Substring($mirror_ou.IndexOf(",")+1)
        Write-Host `nMirror OU is $mirror_ou  -ForegroundColor Green

        Import-Csv "ChangeOU.csv" | ForEach-Object {

            $userid = $_."SamAccountName"

            try
            {
                if(get-aduser $userid) # Check the existense of identity in the AD
                {
                    Get-ADUser $userid | Move-ADobject  -TargetPath $mirror_ou

                    Write-Host " OU Changed for: "$userid # Confirmation message on console
                }
            }

            catch
            {
                Write-Host "AD account not found :" $userid -ForegroundColor Red # Error message on console
            }

        }
    }

    '4'
    {
        $comp_oumove_opt = Read-Host "`nSelect the computer OU moving method`n`n1.Enter computer name manually`n2.Read computer names from CSV file`nYour option"

        Switch($comp_oumove_opt)
        {
            '1'
            {
                $mirror_computer = Read-Host "`nEnter the mirror computer name to locate the OU"
                $mirror_ou = Get-ADComputer $mirror_computer -Properties DistinguishedName | select DistinguishedName
                $mirror_ou = $mirror_ou.DistinguishedName
                $mirror_ou = $mirror_ou.Substring($mirror_ou.IndexOf(",")+1)
                Write-Host `nMirror OU is $mirror_ou  -ForegroundColor Green

                do
                {
                    $Comp_id = Read-Host "`nEnter name the computer which needs to be moved"

                    try
                    {
                        if(get-adcomputer $Comp_id) # Check the existense of identity in the AD
                        {
                            Get-ADcomputer $Comp_id | Move-ADobject  -TargetPath $mirror_ou

                            Write-Host " OU Changed for: "$Comp_id # Confirmation message on console
                        }
                    }

                    catch
                    {
                        Write-Host "Computer not found :" $Comp_id -ForegroundColor Red # Error message on console
                    }
                    
                    $Loop = Read-Host "`nDo you want to create another user account [Y/N]"

                }while($Loop -eq 'Y')
            }

            '2'
            {
                $mirror_computer = Read-Host "`nEnter the mirror computer name to locate the OU"
                $mirror_ou = Get-ADComputer $mirror_computer -Properties DistinguishedName | select DistinguishedName
                $mirror_ou = $mirror_ou.DistinguishedName
                $mirror_ou = $mirror_ou.Substring($mirror_ou.IndexOf(",")+1)
                Write-Host `nMirror OU is $mirror_ou  -ForegroundColor Green

                 Import-Csv "ChangeOU_Computers.csv" | ForEach-Object {

                    $Comp_id = $_."SamAccountName"

                    try
                    {
                        if(get-adcomputer $Comp_id) # Check the existense of identity in the AD
                        {
                            Get-ADcomputer $Comp_id | Move-ADobject  -TargetPath $mirror_ou

                            Write-Host " OU Changed for: "$Comp_id # Confirmation message on console
                        }
                    }

                    catch
                    {
                        Write-Host "Computer not found :" $Comp_id -ForegroundColor Red # Error message on console
                    }

                }
            }
        }
    }
}





# --------------  Verification  ---------------- Use run selection only method to make error free


# Change Computer OU  

<#

Import-Csv "ChangeOU_Computers.csv" | ForEach-Object {

    $Comp_id = $_."SamAccountName"

    Get-ADComputer $Comp_id -Properties *| select CN , canonicalname

    }

#>

# Change User OU  

<#

Import-Csv "ChangeOU.csv" | ForEach-Object {

    $id = $_."SamAccountName"

    Get-ADuser $id -Properties *| select samaccountname , canonicalname

    }

#>
