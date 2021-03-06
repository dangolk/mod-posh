$Title = "Active Directory: Domain Controller Information"
$Header ="Domain Controller Information"
$Comments = "Get information about the Domain Controllers in this Domain."
$Display = "List"
$Author = "Jeff Patton"
$PluginVersion = 1
$PluginCategory = "AD"

$myDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$DomainControllers = $myDomain.DomainControllers |Select-Object -Property Name, OSVersion, SiteName

$Count = 0
$Report = New-Object -TypeName PSobject
foreach ($DomainController in $DomainControllers)
{
    $Count ++
    $DomainControllerDetails = "Name: $($DomainController.Name) | OS: $($DomainController.OSVersion) | Site: $($DomainController.SiteName)"
    Add-Member -InputObject $Report -Value $DomainControllerDetails -MemberType NoteProperty -Name "DC $($Count)"
    }
$Report