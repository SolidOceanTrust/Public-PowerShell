# A Set of Pester tests to use against an EMS server

param(
    [String] $EMSServerName                   = 'emsserver1',
    [int] $ExchangeIntergrationPort           = 100,
    [String] $ExchangeIntergrationVersion     = '44.1.16018.350',
    [int] $WebAppPort                         = 101,
    [String] $WebAppVersion                   = '44.1.33003.1819',    
    [int] $DesktopWebDeployPort               = 102,
    [int] $APIPort                            = 103,
    [String] $EMSBuilding                     = '123 Main St Ave.',
    [int] $PlatformServicePort                = 104,
    [String] $PlatformServiceVersion          = '44.1.33000.364',
    [String] $EmailNotificationServiceVersion = '44.1.33000.325',
    [String] $AutomatedReportServiceVersion   = '44.1.33000.325'
)
    Describe "EMS Server Tests" {
        Context "Server Connectivity" {
            It "Server Should Respond to Pings" {
                Test-Connection -ComputerName $EMSServerName -Count 1 -Quiet | Should -be $true
            }

            It "IIS Should Be Installed" {
                (Get-WindowsFeature -ComputerName $EMSServerName -Name 'Web-WebServer').Installed | Should -Be $true
            }

            It "IIS Should be Running" {
                Get-Process -Name w3wp -ComputerName $EMSServerName | Should -Not -BeNullOrEmpty
            }

            It "Server Should Be Listening On The EMS Exchange Intergration Port: $($ExchangeIntergrationPort)" {
                    (Test-NetConnection -ComputerName $EMSServerName -Port $ExchangeIntergrationPort).TcpTestSucceeded | Should -be $true
            }

            It "Server Should Be Listening On The EMS WebApp Port: $($WebAppPort)" {
                (Test-NetConnection -ComputerName $EMSServerName -Port $WebAppPort).TcpTestSucceeded | Should -be $true
            }

            It "Server Should Be Listening On The EMS DesktopWebDeploy Port: $($DesktopWebDeployPort)" {
                (Test-NetConnection -ComputerName $EMSServerName -Port $DesktopWebDeployPort).TcpTestSucceeded | Should -be $true
            }

            It "Server Should Be Listening On The EMS API $($APIPort)" {
                (Test-NetConnection -ComputerName $EMSServerName -Port $APIPort).TcpTestSucceeded | Should -be $true
            }

            It "Server Should Be Listening On The EMS Platform $($PlatformServicePort)" {
                (Test-NetConnection -ComputerName $EMSServerName -Port $PlatformServicePort).TcpTestSucceeded | Should -be $true
            }
        }
    }

    Describe "EMS Exchange" -Tag ExchangeService {
        Context "Exchange Integration WebService" {
            $Exchangerequest = Invoke-Command -ComputerName $EMSServerName -ArgumentList $ExchangeIntergrationPort -Command {
                param($ExchangeIntergrationPort)
                Invoke-WebRequest -Method Post -Uri "http://localhost:$ExchangeIntergrationPort/Service.asmx/GetVersion"
            }
            It "Should have a HTTP 200 Response on the site" {
                $Exchangerequest.StatusCode | Should -BeExactly 200
            }
            It "GetVersion() Should Return the Expected Version: $ExchangeIntergrationVersion" {
                ($Exchangerequest.content -match $ExchangeIntergrationVersion) | Should -Be $true
            }
        }
    }

    Describe "EMS Web App" -Tag WebApp {
        Context "Web App" {
            It "Should have a HTTP 401 Response on the site" { ## This means the site is configured correctly
                try { $WebApprequest = Invoke-WebRequest -Method Get -Uri "http://$($EMSServerName):$($WebAppPort)" }
                catch { if($WebApprequest.StatusCode -ne 401){
                    $WebApprequest.StatusCode = $WebApprequest.status
                } }
                $WebApprequest.StatusCode | Should -BeExactly 401
            }
            It "EMS Web App Version Should be: $WebAppVersion" {
                $WebAppVer = Invoke-Command -ComputerName $EMSServerName -Command {
                    try {
                        Import-Module -Name WebAdministration -ErrorAction Stop
                        $WebSitePath = Get-ChildItem -Path "iis:\Sites" | Where-Object {$_.Name -eq "EMSWebApp"}
                        $localVer = (Get-Item -Path "$($WebSitePath.physicalPath)\bin\Dea.Web.Core.dll").VersionInfo.FileVersion
                        Write-Output $localVer
                    }
                    catch {
                        Throw "Unable to load IIS PS Module"
                    } 
                }
                $WebAppVer | Should -Be $WebAppVersion
            }
    
        }
    }    

    Describe "EMS API" -Tag API {
        Context "API WebService" {
            $localAdminOnEMS = Get-Credential

            $APIrequest = Invoke-Command -ComputerName $EMSServerName -ArgumentList $APIPort,$localAdminOnEMS -Command {
                    param($APIPort,$localAdminOnEMS)
                    $emsUserName = $localAdminOnEMS.UserName.Split('\')[1]
                    Invoke-WebRequest -Method Post -Uri "http://localhost:$APIPort/Service.asmx/GetBuildings" `
                    -Body @{UserName = "$emsUserName" ; Password = $($localAdminOnEMS.GetNetworkCredential().Password) }
                }
            It "Should have a HTTP 200 Response on the site" {
                $APIrequest.StatusCode | Should -BeExactly 200
            }
            It "GetBuildings Should match $($EMSBuilding) " {
                $clean = $APIrequest.RawContent.Replace("&lt;","").Replace('&gt;','')
                ($clean -match $EMSBuilding) | Should -Be $true
            }
        }
    }

    Describe "Platform Services" -Tag PlatformService {
        Context "Platform Service" {
            $plaformWebRequestBase = Invoke-WebRequest -Method Get -Uri "http://$($EMSServerName):$PlatformServicePort" -MaximumRedirection 0 -ErrorAction Ignore
            $plaformWebRequestRedirect = Invoke-WebRequest -Method Get -Uri "http://$($EMSServerName):$PlatformServicePort/EMSPlatformAPI/status"
            It "Should have a HTTP 301 Response on the site" {
                $plaformWebRequestBase.StatusCode | Should -BeExactly 301
            }
            It "Should Redirect to /EMSPlatformAPI" {
                $plaformWebRequestBase.Headers.Location | Should -Be "http://$($EMSServerName):$PlatformServicePort/EMSPlatformAPI/"
            }
            It "[Redirected Site] Should retrun a HTTP 200 Respose " {
                $plaformWebRequestRedirect.StatusCode | Should -BeExactly 200
            }
            It "Should match the desired version of EMS Plaform Services: $($PlatformServiceVersion)" {
                ($plaformWebRequestRedirect.content -match $PlatformServiceVersion) | Should -Be $true
            }
        }
    }

    Describe "EMS Services" -Tag Services {
        # We need to use WMI calls here in order to return more information about the exe, such as file path
        try {
            $EMailServiceObject = Get-WmiObject -Class Win32_Service -ComputerName $EMSServerName -Filter "Name = 'EMSEmailNotification'" -ErrorAction Stop
            $AutomatedReportObject = Get-WmiObject -Class Win32_Service -ComputerName $EMSServerName -Filter "Name = 'EMSAutomatedReport'" -ErrorAction Stop
        }
        catch {
            Throw "unable to query service(s) on $EMSServerName . Exception: $($_)"
        }
        Context "Email Notification Service Should be Present and Running" {
            It "Email Notification Service is Present" {
                $EMailServiceObject.Status | Should -Not -BeNullOrEmpty
            }
            It "Email Notification Service is Running" {
                $EMailServiceObject.Status | Should -BeExactly "OK"
            }
        }
        Context "Email Notification Service Should be Version: $($EmailNotificationServiceVersion)" {
            It "Email Service is version:" {
                $exePath = $EMailServiceObject.PathName
                $exePathClean = $exePath.Replace(':','$')
                $exePathRemote = "\\$($EMSServerName)\$exePathClean"
                $EmailServiceVersion = (Get-Item -Path $exePathRemote).VersionInfo.FileVersion
                $EmailServiceVersion | Should -Be $EmailNotificationServiceVersion
            }
        }

        Context "Automated Report Service Should be Present and Running" {
            It "Automated Report Service is Present" {
                $AutomatedReportObject.Status | Should -Not -BeNullOrEmpty
            }
            It "Automated REport Service is Running" {
                $AutomatedReportObject.Status | Should -BeExactly "OK"
            }
        }

        Context "Automated Report Service Should be Version: $($AutomatedReportServiceVersion)" {
            It "Automated Report Service is version:" {
                $exePath = $AutomatedReportObject.PathName
                $exePathClean = $exePath.Replace(':','$')
                $exePathRemote = "\\$($EMSServerName)\$exePathClean"
                $AutomatedReportVersion = (Get-Item -Path $exePathRemote).VersionInfo.FileVersion
                $AutomatedReportVersion | Should -Be $AutomatedReportServiceVersion
            }
        }
    }