# Config
$FolderToAnalyse = "G:\Temp\Test-Permissions"
$OutputFile = "C:\Users\admin\Desktop\export.csv"

$OutputList = @()

# Adds the root folder to the OutputList
$OutputList += Get-NTFSAccess -Path $FolderToAnalyse

# Adds all subfolders/subfiles that have different access rules then their parents.
foreach ($SubItem in Get-ChildItem -Path $FolderToAnalyse -Recurse) {

    $SubItemPath = $SubItem.FullName

    if ($SubItem.GetType().Name -eq "DirectoryInfo") {
        $SubItemParentPath = $SubItem.Parent.FullName
    } else {
        $SubItemParentPath = $SubItem.DirectoryName
    }
     
    if ((Get-Acl -Path $SubItemPath).AccessToString -ne (Get-Acl -Path $SubItemParentPath).AccessToString) {
        $OutputList += Get-NTFSAccess -path $SubItemPath
    }
}

# Retrieve the set of accounts/groups name
$AccountsName = ($OutputList | Group-Object -Property Account).Name

# Retrieve the set of subitems (subfolders and subfiles)
$SubItems = ($OutputList | Group-Object -Property FullName)

# Generate the CSV header
$CSV = "Chemin;" + ($AccountsName -join ";") + "`n"

# Generate the subsequent CSV lines
foreach($SubItem in $SubItems) {
    $CSV += $SubItem.Name + ";"
    foreach($Account in $AccountsName) {
        $CSV += ($SubItem.Group | Where-Object {$_.Account.AccountName -eq $Account}).AccessRights
        $CSV += ";"
    }
    $CSV += "`n"
}

# Save the output file
$CSV > $OutputFile