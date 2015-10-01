#Do tags with PowerShell
$rg = "cloudpuzzles"
$location = "West Europe"

New-AzureNetworkSecurityGroup -Name testnsg -ResourceGroupName $rg -Location $location -Tag @( @{Name="Subscription";Value="cloudpuzzles"} )

$tags = (Get-AzureResourceGroup -Name $rg).Tags
$tags += @{Name="Test";Value="yes"}
Set-AzureResourceGroup $rg -Tag $tags