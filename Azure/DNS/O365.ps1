New-AzureDnsZone -Name cloudpuzzles.net -ResourceGroupName cloudpuzzles
$zone = Get-AzureDnsZone -Name cloudpuzzles.net -ResourceGroupName cloudpuzzles
Get-AzureDnsRecordSet –Name “@” –RecordType NS –Zone $zone
$rs = Get-AzureDnsRecordSet -Name awverify -RecordType CNAME -Zone $zone
Add-AzureDnsRecordConfig -RecordSet $rs -Cname awverify.cloudpuzzles.azurewebsites.net
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
$rs = Get-AzureDnsRecordSet -Name "@" -RecordType MX -Zone $zone
Add-AzureDnsRecordConfig -RecordSet $rs -Exchange cloudpuzzles-net.mail.eo.outlook.com -Preference 5
Set-AzureDnsRecordSet -RecordSet $rs