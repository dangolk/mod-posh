<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : vDiagram.ps1
        Created By : jspatton
        Date Coded : 01/04/2012 12:57:27
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/vDiagram.ps1
#>
[cmdletbinding()]
Param
    (
    $ViServer = $false,
    $Cluster = $false,
    [System.IO.FileInfo]$shpFile = ".\My-VI-Shapes.vss"
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        . .\playground\VisioLibrary.ps1
        
        try 
        {
            Add-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction Stop
            } 
        catch 
        {
            Write-Verbose $Error[0].Exception
            }
        
        $SaveFile = [system.Environment]::GetFolderPath('MyDocuments') + "\My_vDrawing.vsd"
        
        }
Process
    {
        Write-Verbose "Create an instance of Visio and create a document based on the Basic Diagram template."
        $AppVisio = New-Object -ComObject Visio.Application
        $docsObj = $AppVisio.Documents
        $DocObj = $docsObj.Add("Basic Diagram.vst")

        Write-Verbose "Set the active page of the document to page 1"
        $pagsObj = $AppVisio.ActiveDocument.Pages
        $pagObj = $pagsObj.Item(1)

        Write-Verbose "Connecting to $VIServer"
        $VIServer = Connect-VIServer $VIServer

        Write-Verbose "Load a set of stencils and select one to drop"
        Write-Verbose "Load the provided stencil from it's path here"
        $stnObj = $AppVisio.Documents.Add($shpFile.FullName)
        $VCObj = $stnObj.Masters.Item("Virtual Center Management Console")
        $HostObj = $stnObj.Masters.Item("ESX Host")
        $MSObj = $stnObj.Masters.Item("Microsoft Server")
        $LXObj = $stnObj.Masters.Item("Linux Server")
        $OtherObj =  $stnObj.Masters.Item("Other Server")
        $CluShp = $stnObj.Masters.Item("Cluster")
        
        If ((Get-Cluster) -ne $Null)
        {
        	If ($Cluster -eq $FALSE)
            { 
                $DrawItems = get-cluster 
                }
            Else 
            {
                $DrawItems = (Get-Cluster $Cluster)
                }
        	
        	$x = 0
        	$VCLocation = $DrawItems | Get-VMHost
        	$y = $VCLocation.Length * 1.50 / 2
        	
        	$VCObject = Add-VisioObject -MasterObj $VCObj -Item $VIServer
        	
        	$x = 1.50
        	$y = 1.50
        	
        	ForEach ($Cluster in $DrawItems)
        	{
        		$CluVisObj = Add-VisioObject -MasterObj $CluShp -Item $Cluster
        		Connect-VisioObject -FirstObj $VCObject -SecondObj $CluVisObj
        		
        		$x=3.00
        		ForEach ($VMHost in (Get-Cluster $Cluster | Get-VMHost))
        		{
        			$Object1 = Add-VisioObject -MasterObj $HostObj -Item $VMHost
        			Connect-VisioObject -FirstObj $CluVisObj -SecondObj $Object1
        			ForEach ($VM in (Get-vmhost $VMHost | get-vm))
        			{		
                        if ($vm.PowerState -eq 'PoweredOn')
                        {
            				$x += 1.50
            				If ($vm.Guest.OSFUllName -eq $Null)
            				{
            					$Object2 = Add-VisioObject -MasterObj $OtherObj -Item $VM
            				    }
            				Else
            				{
            					If ($vm.Guest.OSFUllName.contains("Microsoft") -eq $True)
            					{
            						$Object2 = Add-VisioObject -MasterObj $MSObj -Item $VM
            					   }
            					else
            					{
            						$Object2 = Add-VisioObject -MasterObj $LXObj -Item $VM
            					   }
            				    }	
            				Connect-VisioObject -FirstObj $Object1 -SecondObj $Object2
            				# $Object1 = $Object2
                            }
                        }
        			$x = 3.00
        			$y += 1.50
                    }
                $x = 1.50
        	   }
            }
        Else
        {
        	$DrawItems = Get-VMHost
        	
        	$x = 0
        	$y = $DrawItems.Length * 1.50 / 2
        	
        	$VCObject = Add-VisioObject -MasterObj $VCObj -Item $VIServer
        	
        	$x = 1.50
        	$y = 1.50
        	
        	ForEach ($VMHost in $DrawItems)
        	{
        		$Object1 = Add-VisioObject -MasterObj $HostObj -Item $VMHost
        		Connect-VisioObject -FirstObj $VCObject -SecondObj $Object1
        		ForEach ($VM in (Get-vmhost $VMHost | get-vm))
        		{		
        			$x += 1.50
        			If ($vm.Guest.OSFUllName -eq $Null)
        			{
        				$Object2 = Add-VisioObject -MasterObj $OtherObj -Item $VM
                        }
        			Else
        			{
        				If ($vm.Guest.OSFUllName.contains("Microsoft") -eq $True)
        				{
        					$Object2 = Add-VisioObject -MasterObj $MSObj -Item $VM
        				    }
        				else
        				{
        					$Object2 = Add-VisioObject -MasterObj $LXObj -Item $VM
        				    }
                        }	
        			Connect-VisioObject -FirstObj $Object1 -SecondObj $Object2
        			$Object1 = $Object2
                    }
        		$x = 1.50
        		$y += 1.50
                }
            $x = 1.50
            }
        }
End
    {
        # Resize to fit page
        $pagObj.ResizeToFitContents()

        # Zoom to 50% of the drawing - Not working yet
        #$Application.ActiveWindow.Page = $pagObj.NameU
        #$AppVisio.ActiveWindow.zoom = [double].5

        # Save the diagram
        $DocObj.SaveAs("$Savefile")

        # Quit Visio
        #$AppVisio.Quit()
        Write-Output "Document saved as $savefile"
        Disconnect-VIServer -Server $VIServer -Confirm:$false
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
