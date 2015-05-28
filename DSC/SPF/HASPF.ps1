#requires -Version 5

Configuration SPF
{
    Import-DscResource -Module xSCVMM
    Import-DscResource -Module xSCSPF

    # Set role and instance variables
    $Roles = $AllNodes.Roles | Sort-Object -Unique
    foreach($Role in $Roles)
    {
        $Servers = @($AllNodes.Where{$_.Roles | Where-Object {$_ -eq $Role}}.NodeName)
        Set-Variable -Name ($Role.Replace(" ","").Replace(".","") + "s") -Value $Servers
        if($Servers.Count -eq 1)
        {
            Set-Variable -Name ($Role.Replace(" ","").Replace(".","")) -Value $Servers[0]
        }
    }

    Node $AllNodes.NodeName
    {

        # Install IIS on Web Service servers
        if(
            ($SystemCenter2012R2ServiceProviderFoundationServers  | Where-Object {$_ -eq $Node.NodeName})
        )
        {
            WindowsFeature "Web-WebServer"
            {
                Ensure = "Present"
                Name = "Web-WebServer"
            }

            WindowsFeature "Web-Basic-Auth"
            {
                Ensure = "Present"
                Name = "Web-Basic-Auth"
            }

            WindowsFeature "Web-Windows-Auth"
            {
                Ensure = "Present"
                Name = "Web-Windows-Auth"
            }

            WindowsFeature "Web-Asp-Net45"
            {
                Ensure = "Present"
                Name = "Web-Asp-Net45"
            }

            WindowsFeature "NET-WCF-HTTP-Activation45"
            {
                Ensure = "Present"
                Name = "NET-WCF-HTTP-Activation45"
            }

            WindowsFeature "ManagementOData"
            {
                Ensure = "Present"
                Name = "ManagementOData"
            }

            WindowsFeature "Web-Request-Monitor"
            {
                Ensure = "Present"
                Name = "Web-Request-Monitor"
            }

            WindowsFeature "Web-Http-Tracing"
            {
                Ensure = "Present"
                Name = "Web-Http-Tracing"
            }

            WindowsFeature "Web-Scripting-Tools"
            {
                Ensure = "Present"
                Name = "Web-Scripting-Tools"
            }
        }

        # Install SPF prerequisites
        if($SystemCenter2012R2ServiceProviderFoundationServers | Where-Object {$_ -eq $Node.NodeName})
        {
            if($Node.ASPNETMVC4)
            {
                $ASPNETMVC4 = (Join-Path -Path $Node.ASPNETMVC4 -ChildPath "AspNetMVC4Setup.exe")
            }
            else
            {
                $ASPNETMVC4 = "\Prerequisites\ASPNETMVC4\AspNetMVC4Setup.exe"
            }
            Package "ASPNETMVC4"
            {
                Ensure = "Present"
                Name = "Microsoft ASP.NET MVC 4 Runtime"
                ProductId = ""
                Path = (Join-Path -Path $Node.SourcePath -ChildPath $ASPNETMVC4)
                Arguments = "/q"
                Credential = $Node.InstallerServiceAccount
            }

            if($Node.WCFDataServices50)
            {
                $WCFDataServices50 = (Join-Path -Path $Node.WCFDataServices50 -ChildPath "WCFDataServices.exe")
            }
            else
            {
                $WCFDataServices50 = "\Prerequisites\WCF50\WCFDataServices.exe"
            }
            Package "WCFDataServices50"
            {
                Ensure = "Present"
                Name = "WCF Data Services 5.0 (for OData v3) Primary Components"
                ProductId = ""
                Path = (Join-Path -Path $Node.SourcePath -ChildPath $WCFDataServices50)
                Arguments = "/q"
                Credential = $Node.InstallerServiceAccount
            }

            xSCVMMConsoleSetup "VMMC"
            {
                Ensure = "Present"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
            }
        }

        # Create DependsOn for SPF Server
        $DependsOn = @(
            "[Package]ASPNETMVC4",
            "[Package]WCFDataServices50",
            "[xSCVMMConsoleSetup]VMMC"
        )

        # Install first Server
        if ($SystemCenter2012R2ServiceProviderFoundationServers[0] -eq $Node.NodeName)
        {

            # Install first Web Service Server
            xSCSPFServerSetup "SPF"
            {
                DependsOn = $DependsOn
                Ensure = "Present"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                DatabaseServer = $Node.DatabaseServer
                DatabasePortNumber = $Node.DatabasePortNumber
                SCVMM = $Node.SPFServiceAccount
                SCAdmin = $Node.SPFServiceAccount
                SCProvider = $Node.SPFServiceAccount
                SCUsage = $Node.SPFServiceAccount
                VMMSecurityGroupUsers = $Node.AdminAccount
                AdminSecurityGroupUsers = $Node.AdminAccount
                ProviderSecurityGroupUsers = $Node.AdminAccount
                UsageSecurityGroupUsers = $Node.AdminAccount
            }
        }

        # Wait for first server
        if(
            ($SystemCenter2012R2ServiceProviderFoundationServers | Where-Object {$_ -eq $Node.NodeName}) -and
            (!($SystemCenter2012R2ServiceProviderFoundationServers[0] -eq $Node.NodeName))
        )
        {
            WaitForAll "SPF"
            {
                NodeName = $SystemCenter2012R2ServiceProviderFoundationServers[0]
                ResourceName = "[xSCSPFServerSetup]SPF"
                RetryIntervalSec = 5
                RetryCount = 720
                Credential = $Node.InstallerServiceAccount
            }
            $DependsOn += @("[WaitForAll]SPF")
        }
        
        # Install additional servers
        if(
            ($SystemCenter2012R2ServiceProviderFoundationServers | Where-Object {$_ -eq $Node.NodeName}) -and
            (!($SystemCenter2012R2ServiceProviderFoundationServers[0] -eq $Node.NodeName))
        )
        {
            xSCSPFServerSetup "SPF"
            {
                DependsOn = $DependsOn
                Ensure = "Present"
                SourcePath = $Node.SourcePath
                SetupCredential = $Node.InstallerServiceAccount
                DatabaseServer = $Node.DatabaseServer
                SCVMM = $Node.SPFServiceAccount
                SCAdmin = $Node.SPFServiceAccount
                SCProvider = $Node.SPFServiceAccount
                SCUsage = $Node.SPFServiceAccount
                VMMSecurityGroupUsers = $Node.AdminAccount
                AdminSecurityGroupUsers = $Node.AdminAccount
                ProviderSecurityGroupUsers = $Node.AdminAccount
                UsageSecurityGroupUsers = $Node.AdminAccount
            }
        }
    }
}

$SecurePassword = ConvertTo-SecureString -String "Superman!" -AsPlainText -Force
$InstallerServiceAccount = New-Object System.Management.Automation.PSCredential ("domain\installer", $SecurePassword)
$LocalSystemAccount = New-Object System.Management.Automation.PSCredential ("SYSTEM", $SecurePassword)
$SPFServiceAccount = New-Object System.Management.Automation.PSCredential ("domain\spfsvc", $SecurePassword)

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            SourcePath = "\\MGMT1\Installers"
            InstallerServiceAccount = $InstallerServiceAccount
            LocalSystemAccount = $LocalSystemAccount
            SPFServiceAccount = $SPFServiceAccount
            DatabaseServer = "SQL1.domain.com"
            DatabasePortNumber = "1434"
            AdminAccount = "SOLVOITTEST\Administrator"
        }
        @{
            NodeName = "SPF1.domain.com"
            Roles = @(
                "System Center 2012 R2 Service Provider Foundation Server"
            )
        }
        @{
            NodeName = "SPF2.domain.com"
            Roles = @(
                "System Center 2012 R2 Service Provider Foundation Server"
            )
        }
    )
}

SPF -ConfigurationData $ConfigurationData
Start-DscConfiguration -Path .\SPF -Verbose -Wait -Force