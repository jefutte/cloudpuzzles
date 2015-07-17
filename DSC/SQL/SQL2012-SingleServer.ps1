#requires -Version 5

Configuration SQL
{
    Import-DscResource -Module xSQLServer

    Node $AllNodes.NodeName
    {
        # Set LCM to reboot if needed
        LocalConfigurationManager
        {
            DebugMode = $true
            RebootNodeIfNeeded = $true
            ConfigurationMode = "ApplyOnly"
        }
        
        Group "LocalAdmins"
        {
            Ensure = "Present"
            GroupName = "Administrators"
            MembersToInclude = "$Node.InstallerServiceAccount"
        }

        WindowsFeature "NET-Framework-Core"
        {
            Ensure = "Present"
            Name = "NET-Framework-Core"
            Source = $Node.SourcePath + "\WindowsServer2012R2\sources\sxs"
        }

        # Install SQL Instances
        foreach($SQLServer in $Node.SQLServers)
        {
            $SQLInstanceName = $SQLServer.InstanceName

            $Features = "SQLENGINE"
            {
                xSqlServerSetup ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = "[WindowsFeature]NET-Framework-Core","[Group]LocalAdmins"
                    SourcePath = $Node.SourcePath
                    SetupCredential = $Node.InstallerServiceAccount
                    InstanceName = $SQLInstanceName
                    Features = $Features
                    SQLSvcAccount = $Node.InstallerServiceAccount
                    SQLSysAdminAccounts = $Node.AdminAccount
                    InstallSharedDir = "C:\Program Files\Microsoft SQL Server"
                    InstallSharedWOWDir = "C:\Program Files (x86)\Microsoft SQL Server"
                    InstanceDir = $SQLServer.InstanceDir
                    InstallSQLDataDir = $SQLServer.InstallSQLDataDir
                    SQLUserDBDir = $SQLServer.SQLUserDBDir
                    SQLUserDBLogDir = $SQLServer.SQLUserDBLogDir
                    SQLTempDBDir = $SQLServer.SQLTempDBDir
                    SQLTempDBLogDir = $SQLServer.SQLTempDBLogDir
                    SQLBackupDir = $SQLServer.SQLBackupDir
                }

                xSqlServerFirewall ($Node.NodeName + $SQLInstanceName)
                {
                    DependsOn = ("[xSqlServerSetup]" + $Node.NodeName + $SQLInstanceName)
                    SourcePath = $Node.SourcePath
                    InstanceName = $SQLInstanceName
                    Features = $Features
                }
            }
        }
        # Install SQL Management Tools
        xSqlServerSetup "SQLMGMTTOOLS"
        {
            DependsOn = "[WindowsFeature]NET-Framework-Core","[Group]LocalAdmins"
            SourcePath = $Node.SourcePath
            SetupCredential = $Node.InstallerServiceAccount
            InstanceName = "NULL"
            Features = "SSMS,ADV_SSMS"
        }
    }
}

$SecurePassword = ConvertTo-SecureString -String "password" -AsPlainText -Force
$InstallerServiceAccount = New-Object System.Management.Automation.PSCredential ("cloudpuzzles\sqlsvc", $SecurePassword)

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
            SourcePath = "\\mgmt1\install"
            InstallerServiceAccount = $InstallerServiceAccount
            SQLSysAdminAccounts = @("cloudpuzzles\SQL Admins","cloudpuzzles\jesper")
        }
        @{
            NodeName = "sql1.cloudpuzzles.com"
            SQLServers = @(
                @{
                    InstanceName = "OM"
                    InstanceDir = "E:\Program Files\Microsoft SQL Server"
                    InstallSQLDataDir = "E:\Program Files\Microsoft SQL Server"
                    SQLUserDBDir = "E:\Program Files\Microsoft SQL Server"
                    SQLUserDBLogDir = "E:\Program Files\Microsoft SQL Server"
                    SQLTempDBDir = "E:\Program Files\Microsoft SQL Server"
                    SQLTempDBLogDir = "E:\Program Files\Microsoft SQL Server"
                    SQLBackupDir = "E:\Program Files\Microsoft SQL Server"
                }
                @{
                    InstanceName = "VMM"
                    InstanceDir = "F:\Program Files\Microsoft SQL Server"
                    InstallSQLDataDir = "F:\Program Files\Microsoft SQL Server"
                    SQLUserDBDir = "F:\Program Files\Microsoft SQL Server"
                    SQLUserDBLogDir = "F:\Program Files\Microsoft SQL Server"
                    SQLTempDBDir = "F:\Program Files\Microsoft SQL Server"
                    SQLTempDBLogDir = "F:\Program Files\Microsoft SQL Server"
                    SQLBackupDir = "F:\Program Files\Microsoft SQL Server"
                }
            )
        }
    )
}

SQL -ConfigurationData $ConfigurationData
Set-DscLocalConfigurationManager -Path .\SQL -Verbose
Start-DscConfiguration -Path .\SQL -Verbose -Wait -Force