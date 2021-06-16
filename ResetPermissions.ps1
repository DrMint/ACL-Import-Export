# Config
$FolderToReset = "G:\Temp\Test-Permissions"
$NewOwner = "BUILTIN\Administrateurs"

# Step one: Clears every permissions for the root folder, and adds just the new owner with FullControl access
Clear-NTFSAccess -Path $FolderToReset -DisableInheritance
Set-NTFSOwner -Path $FolderToReset -Account $NewOwner
Add-NTFSAccess –Path $FolderToReset –Account $NewOwner -AccessRights "FullControl"

# Step two: For all subfolder/subfiles, make them inherit their parent's permission and set the owner
Get-ChildItem -Path $FolderToReset -Recurse | Enable-NTFSAccessInheritance -PassThru -RemoveExplicitAccessRules
Get-ChildItem -Path $FolderToReset -Recurse | Set-NTFSOwner -Account $NewOwner
