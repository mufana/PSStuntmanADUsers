param (
    $ModuleLocation = "C:\Users\Administrator\Documents\PSStuntman"
)

Import-Module $ModuleLocation\PSStuntman.dll

$users = Get-Stuntman
$manger = $users[0]
$companyOrgUnitName = $users[0].Company

try {
    New-ADOrganizationalUnit -Name $companyOrgUnitName -ProtectedFromAccidentalDeletion $false
    $createdOrgUnitPath = Get-ADOrganizationalUnit -Filter ({name -eq $companyOrgUnitName})
    New-ADOrganizationalUnit -Name 'Users' -Path $createdOrgUnitPath.DistinguishedName -ProtectedFromAccidentalDeletion $false

    $password = ConvertTo-SecureString -String "DemoCompany123!!" -AsPlainText -Force
    foreach ($user in $users){
        $splatNewADUser = @{
            Name = $user.ExternalId
            GivenName = $user.GivenName
            SurName = $user.FamilyName
            SamAccountName = $user.ExternalId
            Initials = $user.Initials
            AccountPassword = $password
            ChangePasswordAtLogon = $true
            Company = $user.Company
            Title = $user.Title
            StreetAddress = $user.Street
            City = $user.City
            PostalCode = $user.ZipCode
            EmployeeNumber = $user.ExternalId
            Department = $user.UserName
            DisplayName = $user.DisplayName
            EmailAddress = $user.BusinessEmailAddress
            OfficePhone = $user.BusinessPhoneNumber
            Path = "OU=Users,$($createdOrgUnitPath.DistinguishedName)"
        }
        New-ADUser @splatNewADUser
    }

    $adManager = Get-AdUser -Filter {Name -eq $manger.ExternalId}
    $adUsers = Get-AdUser -SearchBase "OU=Users,$($createdOrgUnitPath.DistinguishedName)" -Filter *
    foreach ($adUser in $adUsers){
        Set-ADUser -Identity $adUser.Name -Manager $adManager
    }
} catch {
    throw $PSItem
}
