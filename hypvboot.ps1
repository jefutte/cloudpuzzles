$cluster = Get-Cluster -Name 

$nodes = Get-ClusterNode -Cluster $cluster

$vms = @()
$vmsboot = @()
foreach ($node in $nodes) 
{
    $vms += Get-VM -ComputerName $node.Name | where {$_.Generation -eq "2"}
    foreach ($vm in $vms) 
    {
        $firmware = Get-VMFirmware -VM $vm
        if ($firmware.BootOrder[0].BootType -eq "File")
        {
            $osdisk = Get-VMHardDiskDrive -VM $vm | where {$_.ControllerType -eq "SCSI" -and $_.ControllerNumber -eq "0" -and $_.ControllerLocation -eq "0"}
            $network = Get-VMNetworkAdapter -VM $vm
            $dvd = Get-VMDvdDrive -VM $vm
            Write-Output "Changing boot order on $($vm.VMName)"
            $vmsboot += $vm
            #Set-VMFirmware -VM $vm -BootOrder $osdisk,$dvd,$network
        }
    } 
} 
