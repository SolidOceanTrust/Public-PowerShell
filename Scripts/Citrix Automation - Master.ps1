# Citrix Automation DR

# Configuration Object Instantiation
$CitrixProd = @{}
$CitrixProd.DDCs = @{}
$CitrixProd.DDCs = @{'DDC01' = 'P-DDC01' ; 'DDC02' = 'P-DDC02'}
$CitrixProd.DeliveryGroups = @{}
$CitrixProd.DeliveryGroups = @{'Gen2010' = 'VDI-2010' ; 'Gen2010H' = 'VDI-2010-H' ; 'XA76' = 'XA-76'}
$CitrixProd.MaxVMs = [int]41
$CitrixProd.StoreFrontServers = @{}
$CitrixProd.StoreFrontServers = @{'SF01' = 'P-SF01' ; 'SF02' = 'P-SF02'}

$CitrixDR = @{}
$CitrixDR.DDCs = @{}
$CitrixDR.DDCs = @{'DDC01' = 'USDRDDC01' ; 'DDC02' = 'USDRDDC02'}
$CitrixDR.DeliveryGroups = @{}
$CitrixDR.DeliveryGroups = @{'Gen2010' = 'DR-VDI-2010' ; 'Gen2010H' = 'DR-VDI-2010-H' ; 'XA76' = 'DR-XA-76'}
$CitrixDR.MaxVMs = [int]25
$CitrixDR.StoreFrontServers = @{}
$CitrixDR.StoreFrontServers = @{'SF01' = 'DR-SF01' ; 'SF02' = 'DR-SF02'}


### Pre-Flight Check:
# Ensure DRGEN2010 & DR-VDI-2010-H are in maint. Mode, but have VMs started.

#region Failover
<#
##################################################################################################################
                                        FAILOVER
##################################################################################################################
#>

# Netscaler Disable Access Gateway(s) [PROD]
# ===> Manual Step

# Logoff all XenApp and XenDesktop sessions & put machines into maint. Mode
# Put Delivery Groups into maintenace mode (XD & XA)
# Disable Delivery Groups (XD & XA)
$LogOffDisableProdSB = {
    Add-PSSnapin -Name Citrix.*
    $Gen2010VMs  = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010
    $Gen2010HVMs = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010H
    $XA76VMs     = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.XA76

    $TotalVMs = ($Gen2010VMs.Count + $Gen2010HVMs.Count + $XA76VMs.Count)

    # Shutdown Gen2010 VMs
    $Gen2010VMs | ForEach-Object {
         if($_.PowerState -eq "On")
         {
            New-BrokerHostingPowerAction -Action Shutdown -MachineName $_.MachineName -ActualPriority 10
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
            Start-Sleep -Seconds 5
         }#If "On"
         else
         {
            Write-Host "$($_.MachineName) is Off. Just put it into maint mode"
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#Else
    }#Foreaach $Gen2010VMs
                                    
    # Shutdown Gen2010H VMs
    $Gen2010HVMs | ForEach-Object {
         if($_.PowerState -eq "On")
         {
            New-BrokerHostingPowerAction -Action Shutdown -MachineName $_.MachineName -ActualPriority 10
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
            Start-Sleep -Seconds 5
         }#If "On"
         else
         {
            Write-Host "$($_.MachineName) is Off. Just put it into maint mode"
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#Else
    }#Foreaach $Gen2010HVMs

    # Shutdown XenApp VMs
    $XA76VMs | ForEach-Object {
         if($_.PowerState -eq "On")
         {
            New-BrokerHostingPowerAction -Action Shutdown -MachineName $_.MachineName -ActualPriority 10
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
            Start-Sleep -Seconds 5
         }#If "On"
         else
         {
            Write-Host "$($_.MachineName) is Off. Just put it into maint mode"
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#Else
    }#Foreaach $XA76VMs

    # Wait for Shutdowns to complete
    Start-Sleep -Seconds 120

    # Check for status
    $Gen2010VMsFinal  = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010 -PowerState On
    $Gen2010HVMsFinal = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010H -PowerState On
    $XA76VMsFinal     = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.XA76 -PowerState On

    if( ($Gen2010VMsFinal.Count -or $Gen2010HVMsFinal.Count -or $XA76VMsFinal.Count) -gt 0)
    {
        $TotalVMsFinal = ($Gen2010VMsFinal.Count + $Gen2010HVMsFinal.Count + $XA76VMsFinal.Count)
        Write-Output "There are still $($TotalVMsFinal) VMs powered on. Please force close or wait for these to complete"
    }#if

    # Disable the Prod Delivery Groups
    Set-BrokerDesktopGroup -Name $using:CitrixProd.DeliveryGroups.Gen2010 -InMaintenanceMode $true -Enabled $false
    Set-BrokerDesktopGroup -Name $using:CitrixProd.DeliveryGroups.Gen2010H -InMaintenanceMode $true -Enabled $false
    Set-BrokerDesktopGroup -Name $using:CitrixProd.DeliveryGroups.XA76 -InMaintenanceMode $true -Enabled $false

}#$LogOffDisableProdSB
Invoke-Command -ComputerName $CitrixProd.DDCs.DDC01 -ScriptBlock $LogOffDisableProdSB

# Add GEN2010/H AD groups into DR-VDI-2010/H AD Groups (correctly provisions DR XD groups)
Get-ADGroup -Identity DR-VDI-2010 | Add-ADGroupMember -Members VDI-2010
Get-ADGroup -Identity DR-VDI-2010-H | Add-ADGroupMember -Members VDI-2010-H

<#
Enable & Remove from maint. mode DR Delivery Groups (XD & XA)
Startup DR VMS (XD & XA)
#>

$StartDRSB = {

    #Startup DR VMs , take OUT of maintenance mode
    Add-PSSnapin -Name Citrix.*
    $DRGen2010VMs  = Get-BrokerDesktop -CatalogName $using:CitrixDR.DeliveryGroups.Gen2010
    $DRGen2010HVMs = Get-BrokerDesktop -CatalogName $using:CitrixDR.DeliveryGroups.Gen2010H
    $DRXA76VMs     = Get-BrokerDesktop -CatalogName $using:CitrixDR.DeliveryGroups.XA76

    # Start up DR Gen2010 VMs
    $DRGen2010VMs[0..$($CitrixDR.MaxVMs)] | ForEach-Object { 
        New-BrokerHostingPowerAction -Action TurnOn -MachineName $_.MachineName -ActualPriority 10 
        Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $false 
        Start-Sleep -Seconds 2
        }#foreach DR Gen2010

    # Start up DR Gen2010H VMs
    $DRGen2010HVMs | ForEach-Object { 
        New-BrokerHostingPowerAction -Action TurnOn -MachineName $_.MachineName -ActualPriority 10 
        Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $false 
        Start-Sleep -Seconds 2
        }#foreach DR Gen2010H

    # Start up DR XenApp VMs
    $DRXA76VMs | ForEach-Object { 
        New-BrokerHostingPowerAction -Action TurnOn -MachineName $_.MachineName -ActualPriority 10 
        Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $false 
        Start-Sleep -Seconds 2
        }#foreach DR XA76 Vms

    # Wait for VMs to boot up and register
    Start-Sleep -Seconds 120

    # Enable the Delivery Groups
    Set-BrokerDesktopGroup -Name $using:CitrixDR.DeliveryGroups.Gen2010 -InMaintenanceMode $false -Enabled $true
    Set-BrokerDesktopGroup -Name $using:CitrixDR.DeliveryGroups.Gen2010H -InMaintenanceMode $false -Enabled $true
    Set-BrokerDesktopGroup -Name $using:CitrixDR.DeliveryGroups.XA76 -InMaintenanceMode $false -Enabled $true

}#$StartDRSB
Invoke-Command -ComputerName $CitrixDR.DDCs.DDC01 -ScriptBlock $StartDRSB

# Reboot DR Storefront Servers
$CitrixDR.StoreFrontServers.Values | ForEach-Object {
    New-EventLog -LogName System -Source "BCP Failover" -ComputerName $_
    Write-EventLog -LogName System -Source "BCP Failover" -EntryType Information -EventId 9999 -Message "BCP Reboot, Failover"
    Restart-Computer -ComputerName $_ -Force
}#Foreach

#endregion

#region failback
<#
##################################################################################################################
                                        FAILBACK
##################################################################################################################
#>

# Netscaler Enable Access Gateway(s) [PROD]
## ====> Manual Step

# Logoff all DR XenApp and XenDesktop sessions & put machines into maint. Mode
# Disable DR Delivery Groups (XD & XA)
$LogOffDRSB = {
    Add-PSSnapin -Name Citrix.*
    $DRGen2010VMs  = Get-BrokerDesktop -CatalogName $using:CitrixDR.DeliveryGroups.Gen2010
    $DRGen2010HVMs = Get-BrokerDesktop -CatalogName $using:CitrixDR.DeliveryGroups.Gen2010H
    $DRXA76VMs     = Get-BrokerDesktop -CatalogName $using:CitrixDR.DeliveryGroups.XA76

    # Shutdown DR Gen2010 VMs
    $DRGen2010VMs[0..$($CitrixDR.MaxVMs)] | ForEach-Object {
         if($_.PowerState -eq "On")
         {
            New-BrokerHostingPowerAction -Action Shutdown -MachineName $_.MachineName -ActualPriority 10
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#If "On"
         else
         {
            Write-Host "$($_.MachineName) is Off. Just put it into maint mode"
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#Else
    }#Foreaach $DRGen2010VMs
                                    
    # Shutdown DR Gen2010H VMs
    $DRGen2010HVMs | ForEach-Object {
         if($_.PowerState -eq "On")
         {
            New-BrokerHostingPowerAction -Action Shutdown -MachineName $_.MachineName -ActualPriority 10
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#If "On"
         else
         {
            Write-Host "$($_.MachineName) is Off. Just put it into maint mode"
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#Else
    }#Foreaach $DRGen2010HVMs

    # Shutdown DR XenApp VMs
    $DRXA76VMs | ForEach-Object {
         if($_.PowerState -eq "On")
         {
            New-BrokerHostingPowerAction -Action Shutdown -MachineName $_.MachineName -ActualPriority 10
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#If "On"
         else
         {
            Write-Host "$($_.MachineName) is Off. Just put it into maint mode"
            Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $true 
         }#Else
    }#Foreaach $DRXA76VMs

    # Wait for Shutdowns to complete
    Start-Sleep -Seconds 120

    # Check for status
    $DRGen2010VMsFinal  = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010 -PowerState On
    $DRGen2010HVMsFinal = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010H -PowerState On
    $DRXA76VMsFinal     = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.XA76 -PowerState On

    if( ($DRGen2010VMsFinal.Count -or $DRGen2010HVMsFinal.Count -or $DRXA76VMsFinal.Count) -gt 0)
    {
        $TotalVMsFinal = ($DRGen2010VMsFinal.Count + $DRGen2010HVMsFinal.Count + $DRXA76VMsFinal.Count)
        Write-Output "There are still $($TotalVMsFinal) VMs powered on. Please force close or wait for these to complete"
    }

    # Disable the DR Delivery Groups
    Set-BrokerDesktopGroup -Name $CitrixDR.DeliveryGroups.Gen2010 -InMaintenanceMode $true -Enabled $false
    Set-BrokerDesktopGroup -Name $CitrixDR.DeliveryGroups.Gen2010H -InMaintenanceMode $true -Enabled $false
    Set-BrokerDesktopGroup -Name $CitrixDR.DeliveryGroups.XA76 -InMaintenanceMode $true -Enabled $false

}#$LogOffDRSB
Invoke-Command -ComputerName $CitrixDR.DDCs.DDC01 -ScriptBlock $LogOffDRSB

# Remove Nested AD Groups for seamless config changes
Get-ADGroup -Identity DR-VDI-2010 | Remove-ADGroupMember -Members VDI-2010 -Confirm:$false
Get-ADGroup -Identity DR-VDI-2010-H | Remove-ADGroupMember -Members VDI-2010-H -Confirm:$false 


# Turn on Production VMs and Enable Delivery Groups
$StartProdSB = {

    #Startup DR VMs , take OUT of maintenance mode
    Add-PSSnapin -Name Citrix.*
    $ProdGen2010VMs  = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010
    $PordGen2010HVMs = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.Gen2010H
    $ProdXA76VMs     = Get-BrokerDesktop -CatalogName $using:CitrixProd.DeliveryGroups.XA76

    # Start up Prod Gen2010 VMs
    $ProdGen2010VMs[0..$($CitrixProd.MaxVMs)] | ForEach-Object { 
        New-BrokerHostingPowerAction -Action TurnOn -MachineName $_.MachineName -ActualPriority 10 
        Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $false 
        Start-Sleep -Seconds 2
        }#foreach Prod Gen2010

    # Start up Prod Gen2010H VMs
    $PordGen2010HVMs[0..5] | ForEach-Object { 
        New-BrokerHostingPowerAction -Action TurnOn -MachineName $_.MachineName -ActualPriority 10 
        Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $false 
        Start-Sleep -Seconds 2
        }#foreach Prod Gen2010H

    # Start up Prod XenApp VMs
    $ProdXA76VMs | ForEach-Object { 
        New-BrokerHostingPowerAction -Action TurnOn -MachineName $_.MachineName -ActualPriority 10 
        Set-BrokerMachineMaintenanceMode -InputObject (Get-BrokerMachine -DNSName $_.DNSName) $false 
        Start-Sleep -Seconds 2
        }#foreach Prod XA76 Vms

    # Wait for VMs to boot up and register
    Start-Sleep -Seconds 120

    # Enable the Delivery Groups
    Set-BrokerDesktopGroup -Name $using:CitrixProd.DeliveryGroups.Gen2010 -InMaintenanceMode $false -Enabled $true
    Set-BrokerDesktopGroup -Name $using:CitrixProd.DeliveryGroups.Gen2010H -InMaintenanceMode $false -Enabled $true
    Set-BrokerDesktopGroup -Name $using:CitrixProd.DeliveryGroups.XA76 -InMaintenanceMode $false -Enabled $true

}#$StartDRSB
Invoke-Command -ComputerName $CitrixDR.DDCs.DDC01 -ScriptBlock $StartProdSB

# Reboot Prod Storefront Servers
$CitrixProd.StoreFrontServers.Values | ForEach-Object {
    New-EventLog -LogName System -Source "BCP Failover" -ComputerName $_
    Write-EventLog -LogName System -Source "BCP Failover" -EntryType Information -EventId 9999 -Message "BCP Reboot, Failover"
    Restart-Computer -ComputerName $_ -Force
}#Foreach
#endregion