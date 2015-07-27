Switch-AzureMode AzureServiceManagement
$child = New-AzureDnsZone -Name aadtest.cloudpuzzles.net -ResourceGroupName cloudpuzzles
$childnsrs = Get-AzureDnsRecordSet -Zone $child -Name "@" -RecordType NS

$parent = Get-AzureDnsZone -Name cloudpuzzles.net -ResourceGroupName cloudpuzzles
$parentnsrs = New-AzureDnsRecordSet -Zone $parent -Name "aadtest" -RecordType NS -Ttl 3600
$parentnsrs.Records = $childnsrs.Records
Set-AzureDnsRecordSet -RecordSet $parentnsrs