# Install PnP PowerShell
Install-Module -Name "PnP.PowerShell"

# Connect to on-prem SharePoint instance
Connect-PnPOnline -URL your_sharepoint_instance_url

# List sites/subsites
Get-PnPWeb
Get-PnPSubWebs
Get-PnPSubWebs -Identity site_id -Recurse

# Delete sites/subsites
Remove-PnPWeb -Identity site_id

# Create sites/subsites
New-PnPWeb -Title "Project A Web" -Url projectA -Description "Information about Project A" -Locale 1033 -Template "STS#0"

# List all SharePoint groups
Connect-PnPOnline -URL your_sharepoint_instance_url
Get-PnPGroup | Format-Table -AutoSize | Tee-Object AllSharePointGroups.log

# Remove SharePoint groups by Name or ID
Remove-PnPGroup -Identity "Name_Of_SharePoint_Group"

# List Site Structure
Get-PnPSubWebs -Recurse -IncludeRootWeb | Format-Table -AutoSize | Tee-Object SiteStructure.txt
Get-PnPSubwebs -Recurse -IncludeRootWeb | Select-Object Title,ServerRelativeUrl,Url,Id | Export-Csv -Path .\SiteStructure.csv


# List all Document Libraries and Lists
# Set root url and site credentials.
$RootSiteUrl = "your_sharepoint_instance_url"
$UserName = "your_username"
$Password = ConvertTo-SecureString "your_password" -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential ($Username,$Password)

# Connect to root site and recursively retrieve all subsites.
Connect-PnPOnline -Url $RootSiteUrl -Credentials $Cred
$SubsitesUrls = Get-PnPSubwebs -Recurse -IncludeRootWeb | Select-Object Url

# Connect to each subsite and retrieve list of site assets.
ForEach ($SiteUrl in $SubsitesUrls) {
    $ConnectionUrl = $SiteUrl."Url"
    Connect-PnPOnline -Url $ConnectionUrl -Credentials $Cred
    $FileName = Get-PnPWeb | Select-Object -ExpandProperty Title
    $FileName += ".csv"
    Get-PnPList | Select-Object BaseType,Title,ParentWebUrl,DefaultViewUrl,Description,DocumentTemplateUrl,Id,Created,LastItemDeletedDate,LastItemModifiedDate,LastItemUserModifiedDate | Export-Csv $FileName
}

# Export a list of Document Library contents recursively.
# Usage: GetSiteContents("Site_Url"), GetLibContents("Document_Library_Name")
$UserName = "your_username"
$Password = ConvertTo-SecureString "your_password" -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential ($Username,$Password)

function GetSiteContents($url) {
    Connect-PnPOnline -URL $url -Credentials $Cred
    Get-PnPList
}

function GetLibContents($name) {
    $FileName = Get-PnPWeb | Select-Object -ExpandProperty Title
    $FileName += " - "
    $FileName += $name
    $FileName += ".csv"
    Get-PnPFolderItem -FolderSiteRelativeUrl $name -Recursive | Select-Object TypedObject,ItemCount,Name,ServerRelativeUrl,TimeCreated,TimeLastModified,UniqueId | Export-Csv -Path .\$FileName
}