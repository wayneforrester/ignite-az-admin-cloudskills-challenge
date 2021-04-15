# Deploy portal web app
# get app from github
git clone https://github.com/MicrosoftDocs/mslearn-improve-app-scalability-resiliency-with-load-balancer.git
cd mslearn-improve-app-scalability-resiliency-with-load-balancer

# Create VMs in availability set
bash create-high-availability-vm-with-sets.sh learn-1dd78f1e-399c-47fc-80fa-1382682d3da5

# Create public IP
$Location = $(Get-AzureRmResourceGroup -ResourceGroupName learn-1dd78f1e-399c-47fc-80fa-1382682d3da5).Location

$publicIP = New-AzPublicIpAddress `
  -ResourceGroupName learn-1dd78f1e-399c-47fc-80fa-1382682d3da5 `
  -Location $Location `
  -AllocationMethod "Static" `
  -Name "myPublicIP"

# Create front-end IP on load balancer
$frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "myFrontEnd" `
  -PublicIpAddress $publicIP

# Create load balancer
# Create back-end address pool
$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "myBackEndPool"

# Create health probe
$probe = New-AzLoadBalancerProbeConfig `
  -Name "myHealthProbe" `
  -Protocol http `
  -Port 80 `
  -IntervalInSeconds 5 `
  -ProbeCount 2 `
  -RequestPath "/"

# Create load balancer rules to define how traffic is distubuted to VMs
$lbrule = New-AzLoadBalancerRuleConfig `
  -Name "myLoadBalancerRule" `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $probe

# Create basic load balancer
$lb = New-AzLoadBalancer `
  -ResourceGroupName learn-1dd78f1e-399c-47fc-80fa-1382682d3da5 `
  -Name 'MyLoadBalancer' `
  -Location $Location `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool `
  -Probe $probe `
  -LoadBalancingRule $lbrule

# Connect VMs to back-end pool by updating nics
$nic1 = Get-AzNetworkInterface -ResourceGroupName learn-1dd78f1e-399c-47fc-80fa-1382682d3da5 -Name "webNic1"
$nic2 = Get-AzNetworkInterface -ResourceGroupName learn-1dd78f1e-399c-47fc-80fa-1382682d3da5 -Name "webNic2"

$nic1.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool
$nic2.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool

Set-AzNetworkInterface -NetworkInterface $nic1 -AsJob
Set-AzNetworkInterface -NetworkInterface $nic2 -AsJob

# Get public IP of load balancer and URL
Write-Host http://$($(Get-AzPublicIPAddress `
  -ResourceGroupName learn-1dd78f1e-399c-47fc-80fa-1382682d3da5 `
  -Name "myPublicIP").IpAddress)

