# Config
$InputFile = "C:\Users\admin\Desktop\export.csv"


$CSV = Import-Csv -Path $InputFile -Delimiter ";"

# Get the list of user/group names
$AccountsName = @()
foreach ($property in ($CSV | Get-Member -MemberType NoteProperty)) { 
    if ($property.Name -ne "Chemin") {
        $AccountsName += $property.Name
    }
}

foreach ($Line in $CSV) {
    $Path = $Line.Chemin

    # Verify if that the expected permissions are present on that item
    $NeedToChange = $false
    foreach ($User in $AccountsName) {

        $NewPermissionForUser = $Line | select -expand $User
        if ($NewPermissionForUser -eq "") {
            $NewPermissionForUser = $null
        }

        $CurrentPermissionForUser = (Get-NTFSAccess -Path $Path -Account $User).AccessRights

        if ($NewPermissionForUser -ne $CurrentPermissionForUser) {
            $NeedToChange = $true
            break
        }
    }

    # Verify that there isn't some unexpected permissions
    # (a permission for a user that isn't present in the CSV InputFile)
    foreach ($User in (Get-NTFSAccess -Path $Path).Account.AccountName) {
        if ($UsersCSV.Contains($User) -eq $false) {
            $NeedToChange = $true
            break
        }
    } 

    # If the item isn't compliant with the expected permissions
    # Clear all permissions and add the expected ones
    if ($NeedToChange) {
        Clear-NTFSAccess -Path $Path -DisableInheritance

        foreach ($User in $AccountsName) {
            $PermissionForUser = $Line | select -expand $User

            if ($PermissionForUser -ne "") {
                Add-NTFSAccess –Path $Path  –Account $User -AccessRights $PermissionForUser -AppliesTo ThisFolderSubfoldersAndFiles
            }
        }
    }

}
