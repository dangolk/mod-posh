http://blogs.technet.com/b/grouppolicy/archive/2011/06/10/listing-all-gpos-in-the-current-forest.aspx
http://blogs.technet.com/b/heyscriptingguy/archive/2009/02/10/how-can-get-a-list-of-all-my-orphaned-group-policy-objects.aspx

Function Get-GPO()
{
 
 $gpm=New-Object -ComObject gpmgmt.gpm
 $constants = $gpm.GetConstants()
 $gpmDomain = $gpm.GetDomain($env:userDNSdomain,$null,$constants.useanydc)
 $gpmSearchCriteria = $gpm.CreateSearchCriteria()
 $gpo=$gpmdomain.SearchGPOs($gpmSearchCriteria)
 if($verbose)
  { 
   $gpo 
  }
 ELSE
  {
   foreach($ogpo in $gpo)
    {
     $hash += @{ $ogpo.ID = $ogpo.DisplayName }
    }
     format-table -inputobject $hash -autosize
  } #end else
} #end Get-GPO

Function Get-UnlinkedGPO()
{
$gpm=New-Object -ComObject gpmgmt.gpm
$constants = $gpm.GetConstants()
$gpmDomain = $gpm.GetDomain($env:userDNSdomain,$null,$constants.useanydc)
$gpmSearchCriteria = $gpm.CreateSearchCriteria()
$gpoList= $gpmDomain.SearchGPOs($gpmSearchCriteria)


$unlinkedGPO = 0
foreach($objGPO in $gpoList)
{
  $gpmSearchCriteria = $gpm.CreateSearchCriteria()
  $gpmSearchCriteria.add($constants.SearchPropertySomLinks, $constants.SearchOpContains, $objGPO)
  $somList = $gpmDomain.SearchSoms($gpmSearchCriteria)
   if($somList.count -eq 0)
     { 
      "$($objGPO.id) `t $($objGPO.displayname)" 
      $unlinkedGPO +=1
     }
}
if($unlinkedGPO -eq 0) 
  { 
    Write-Host "no unlinked gpos"
  }

} #end Get-UnlinkedGPO
