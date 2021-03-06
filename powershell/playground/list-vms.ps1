#Requires -PsSnapIn VMware.VimAutomation.Core
$VMs = Get-VM
$Report = @()
foreach ($vm in $VMs)
{
    If ($vm.PowerState -eq "PoweredOn")
    {
        $LineItem = New-Object -TypeName PSObject -Property @{
            Name = $Vm.Name
            Version = $Vm.Version
            NumCPU = $Vm.NumCPU
            MemoryMB = $Vm.MemoryMB
            HDCapKB = (Get-HardDisk -vm $vm).CapacityKB
            HDPersistence = (Get-HardDisk -vm $vm).Persistence
            NetworkAdapter = (Get-NetworkAdapter -vm $vm).Type
            Network = (Get-NetworkAdapter -vm $VM).NetworkName
            MAC = (Get-NetworkAdapter -vm $vm).MacAddress
            Host = $vm.Host.Name
            ResourcePool = $VM.ResourcePool
            DataStore = (Get-DataStore -vm $vm).Name
            }
        $Report += $LineItem
    }
}

$Report |Format-Table -AutoSize