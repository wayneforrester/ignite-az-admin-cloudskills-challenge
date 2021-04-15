# Create resrouce group
$resourceGroup = 'learn-file-sync-rg'
$location = 'EastUS'
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create subnet and vnet
$subnetConfig = New-AzVirtualNetworkSubnetConfig `
-Name Syncpublicnet `
-AddressPrefix 10.0.0.0/24

$virtualNetwork = New-AzVirtualNetwork `
-Name Syncvnet `
-AddressPrefix 10.0.0.0/16 `
-Location $location `
-ResourceGroupName $resourceGroup `
-Subnet $subnetConfig

# Set user name and password
$cred = Get-Credential

#learnadmin

# Create Windows Server
New-Azvm `
 -Name FileServerLocal `
 -Credential $cred `
 -ResourceGroupName $resourceGroup `
 -Size Standard_DS1_v2 `
 -VirtualNetworkName Syncvnet `
 -SubnetName Syncpublicnet `
 -Image "MicrosoftWindowsServer:WindowsServer:2019-Datacenter-with-Containers:latest"

# download sample data to D:
# curl https://github.com/MicrosoftDocs/mslearn-extend-share-capacity-with-azure-file-sync/blob/master/resources/CADFolder.zip?raw=true -L -o CADFolder.zip

# On server install Az modules
Install-Module -Name Az

# Complete sync assessment
Invoke-AzStorageSyncCompatibilityCheck -Path D:\CADFolder

# Test files only
Invoke-AzStorageSyncCompatibilityCheck -Path D:\CADFolder -SkipSystemChecks

# Test system requirements only
Invoke-AzStorageSyncCompatibilityCheck -ComputerName localhost

# Save results to CSV
$results=Invoke-AzStorageSyncCompatibilityCheck -Path D:\CADFolder
$results | Select-Object -Property Type, Path, Level, Description | Export-Csv -Path D:\assessment-results.csv

# Create File Sync service in portal:
# https://docs.microsoft.com/en-ca/learn/modules/extend-share-capacity-with-azure-file-sync/6-exercise-create-file-sync-resources

# Setup Windows Server:
# https://docs.microsoft.com/en-ca/learn/modules/extend-share-capacity-with-azure-file-sync/7-set-up-azure-file-sync-windows-server

<#
NB: Delete the Azure File Sync resources individually, in the reverse order from which you created them, as shown here:

1. In Azure, delete the server endpoint and cloud endpoints in the sync group.
2. Delete the sync group.
3. Delete the Storage Sync Service.
4. You can delete the rest of the resources you created by deleting the resource group that contains the remaining resources.

#>



