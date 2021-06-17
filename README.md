# ACL-Import-Export

Windows Access Control management can be difficult when dealing with thousands of folders and files: erratic use of specific permissions for certain group or accounts, broken inheritance, multiple ACE for the same entity...

## Analysis
The first step is to analyze the current situation with AnalysePermissions.ps1. Simply change the folder to analyse and the path to the output file. The output file is a CSV containing the path of the subitems (files and folders), and the permission each entity has over it. The list of entity is derived from the permissions found in the ACLs. Subitems with the same permissions as their parent are excluded. This way, you are only presented where permissions differ.

## Management
Thanks to the analysis, you can easily detect anomalies in the permissions, user-level permissions that could be integrated into a group, multiple ACE for the same entity, dangerous use of FullControl permissions... You can use the analysis as a baseline and then modify the CSV file to your liking. Once you have a good permission structure you are ready to apply the changes.

## Apply
Once your permission structure has been clarified, we can now run ApplyPermissions.ps1. This will scan through the subitems recursively and compare the expected permissions with the current ones. If they differ, the program will reset the subitem permission and apply the expected ones.

## Reset
If you want to reset all permission for a folder and its subitems, just run ResetPermissions.ps1. This will removed all permission except a FullControl for its owner. The desired owner can be change in the config section of the program source file. 
