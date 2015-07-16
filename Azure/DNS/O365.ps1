Switch-AzureMode -Name AzureResourceManager
Add-AzureAccount
Select-AzureSubscription -SubscriptionName "JJ"
Register-AzureProvider -ProviderNamespace Microsoft.Network
$zone = Get-AzureDnsZone -Name cloudpuzzles.net -ResourceGroupName JJ
$rs = Get-AzureDnsRecordSet -Name "@" -RecordType TXT -Zone $zone
Add-AzureDnsRecordConfig -RecordSet $rs -Value "MS=ms12345678"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "sip" -RecordType CNAME -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs -Cname "sipdir.online.lync.com"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "lyncdiscover" -RecordType CNAME -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs -Cname "webdir.online.lync.com"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "msoid" -RecordType CNAME -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs -Cname "clientconfig.microsoftonline-p.net"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "enterpriseregistration" -RecordType CNAME -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs -Cname "enterpriseregistration.windows.net"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "enterpriseenrollment" -RecordType CNAME -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs -Cname "enterpriseenrollment.manage.microsoft.com"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "_sip._tls" -RecordType SRV -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs –Priority 100 –Weight 1 –Port 443 –Target "sipdir.online.lync.com"
Set-AzureDnsRecordSet -RecordSet $rs
$rs = New-AzureDnsRecordSet -Name "_sipfederationtls._tcp" -RecordType SRV -Zone $zone -Ttl 3600
Add-AzureDnsRecordConfig -RecordSet $rs –Priority 100 –Weight 1 –Port 5061 –Target "sipfed.online.lync.com"
Set-AzureDnsRecordSet -RecordSet $rs