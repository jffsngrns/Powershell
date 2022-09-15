function New-BulkADUsersOUnSecGrp {
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$True)][String]$Name
	)

		New-ADOrganizationalUnit -Name $Name -Path "DC=Adatum,DC=com"
		New-ADGroup -Name $Name  -GroupScope Global -GroupCategory Security -Path "OU=$Name,DC=Adatum,DC=com"

	#import the data from NewADUsers.csv in the $ADUsers variable
	$ADUsers = Import-Csv C:\Windows\Temp\NewAdUsers.csv 

		#loop through each row of user info in the csv file
		foreach ($User in $ADUsers) {

		#read user data from each field in each row and assign the data to a variable
		$Username = $User.username
		$Firstname = $User.firstname
		$Lastname = $User.lastname

			#check to see if the user already exists in AD
			if (Get-ADUser -F { SamAccountName -eq $username }) {

			#if user does exist, give this warning	
			Write-Warning "User account for $username already exists in AD." 
			}
				else {

				#if user does not exist then create user
				#created account will be in the OU provided by the $OU variable on the csv file
				New-ADUser `
				-SamAccountName $Username `
				-UserPrincipalName "$Username@adatum.com" `
				-Name "$Firstname $Lastname" `
				-GivenName $Firstname `
				-Surname $Lastname `
				-Enabled $True `
				-DisplayName "$Lastname, $Firstname" `
				-Path "OU=$Name,DC=Adatum,DC=com" `
				-City $city `
				-Company $company `
				-State $state `
				-StreetAddress $streetaddress `
				-OfficePhone $telephone `
				-EmailAddress $email `
				-Title $jobtitle `
				-Department $department `
				-AccountPassword (convertto-securestring "Pa55w.rd" -AsPlainText -Force) -ChangePasswordAtLogon $True

                Add-ADGroupMember -Identity $Name -Members $User.username

					#if user is created, show this message
					Write-Host "The user account for $username is created."
    				
                } #end else
		} #end for each
} #end function

function Get-CreatedADUsersReport {

    #get today's date
    $createdToday = ((Get-Date).AddDays(-1)).Date

    #get AD users information that was created today
    Get-ADUser -Filter {whenCreated -ge $createdToday} -Properties whenCreated | Select-Object Name,DistinguishedName,whenCreated | Sort-Object whenCreated |

    #export report of created AD users
    Export-Csv c:\windows\temp\CreatedADUsersReport.csv
}