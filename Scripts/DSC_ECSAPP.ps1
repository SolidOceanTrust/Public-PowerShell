#ECS Server Requirements

# IIS
# .NET 4.5.2
# MSMQ
# FileZilla FTP Client

#DB
# SQL 2014 Enterprise/Std

#APP
# SQL Client Components, Integration Svcs, Reporting Svcs
# Roles = App or DB
    #DB = (SQL)
    #App = SQL Client Components,Intergration,Reporting SVCs

configuration Build_EzeAppServer
{
    # One can evaluate expressions to get the node list
    # E.g: $AllNodes.Where("Role -eq Web").NodeName
    
    Param
    (
        $WinConfigSourcePath = 'c:\Scripts\_Modules\WinConfig',
        $WinConfigDestinationPath = 'c:\Program Files\WindowsPowerShell\Modules',
        [Parameter(Mandatory)] 
        [String] $nodename
    )#Params
    
    
    $InstallsDir = "\\ussystems02\Software$\Server2012R2"
    
    #Import the module to avoid the build WARNINGS for the mof creation
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'
    
    node $nodename
    {
        # Call Resource Provider
        # E.g: WindowsFeature, File
        WindowsFeature DotNet35-Features
        {
           Ensure = "Present"
           Name   = "NET-Framework-Features"
           Source = "$InstallsDir\sources\sxs"
        }
        WindowsFeature DotNet35-Core
        {
           Ensure = "Present"
           Name   = "NET-Framework-Core"
           DependsOn = '[WindowsFeature]DotNet35-Features'
           Source = "$InstallsDir\sources\sxs"
        }
        WindowsFeature DotNet45FrameWork
        {
           Ensure = "Present"
           Name   = "AS-NET-Framework"
           Source = "$InstallsDir\sources\sxs"
        }
        WindowsFeature IIS
        {
           Ensure = "Present"
           Name   = "Web-WebServer"
           IncludeAllSubFeature = $true
           DependsOn = "[WindowsFeature]DotNet35-Features"
           Source = "$InstallsDir\sources\sxs"
           
        }
        WindowsFeature HTTPMSMQ
        {
           Ensure = "Present"
           Name   = "AS-MSMQ-Activation"
           DependsOn = "[WindowsFeature]IIS"
        }
        WindowsFeature MGMTTOOLS
        {
           Ensure = "Present"
           Name   = "Web-Mgmt-Tools"
           IncludeAllSubFeature = $true
        }
        WindowsFeature MSMQ
        {
            Ensure = "Present"
            Name   = "MSMQ"
            IncludeAllSubFeature = $true
        }
        WindowsFeature TELNETCLIENT
        {
            Ensure = "Present"
            Name   = "Telnet-Client"
        }
        File WinConfigModule
        {
            Ensure          = "Present"
            SourcePath      = "C:\DSC\WinConfig"
            DestinationPath = "$WinConfigDestinationPath\WinConfig"
            Type            = "Directory"
            Recurse         = $true
        }

        ##TO Do
        <#
            FileZilla FTP Client
            Labtech Agent
            Symantec AV Agent
            VC++ 2005-2015

            PageFile

            <WinConfig Module>
            RDP Enabled
            Windows FW Disabled
            Explorer Config Options

        #>
        
  
    }
}# configuration Build_EzeAppServer

Copy-Item -Path 'C:\Scripts\_Modules\WinConfig' -Destination 'C:\DSC\WinConfig' -Recurse -Force
Set-Location c:\DSC

#Local Option:
#ECS -nodename $env:COMPUTERNAME -OutputPath c:\DSC

#Start-DscConfiguration -Path c:\DSC\ -Wait -Verbose -Force

#Remote Option:
# $cimSession = New-CimSession -ComputerName $nondename -Credential (Get-Credential)
# Start-DscConfiguration -Path C:\DSC\ -Wait -Verbose -CimSession $cimSession -Force