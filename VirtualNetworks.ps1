Connect-AzAccount

# creates 2 WIndows VMs connected to same vnet
$Location = "WestUS"
New-AzResourceGroup -Name vm-networks -Location $Location

$Subnet = New-AzVirtualNetworkSubnetConfig -Name default -AddressPrefix 10.0.0.0/24
New-AzVirtualNetwork -Name myVnet -ResourceGroupName vm-networks -Location $Location -AddressPrefix 10.0.0.0/16 -Subnet $Subnet

New-AzVm `
 -ResourceGroupName "vm-networks" `
 -Name "dataProcStage1" `
 -VirtualNetworkName "myVnet" `
 -SubnetName "default" `
 -image "Win2016Datacenter" `
 -Size "Standard_DS2_v2"

 Get-AzPublicIpAddress -Name dataProcStage1

 New-AzVm `
 -ResourceGroupName "vm-networks" `
 -Name "dataProcStage2" `
 -VirtualNetworkName "myVnet" `
 -SubnetName "default" `
 -image "Win2016Datacenter" `
 -Size "Standard_DS2_v2"

# Disassociate the public IP address that was created by default for the VM
$nic = Get-AzNetworkInterface -Name dataProcStage2 -ResourceGroup vm-networks
$nic.IpConfigurations.publicipaddress.id = $null
Set-AzNetworkInterface -NetworkInterface $nic

# Delete resource group and all resources deployed to it
Remove-AzResourceGroup -Name vm-networks
