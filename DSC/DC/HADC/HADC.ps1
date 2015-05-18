# A configuration to Create High Availability Domain Controller 

$passwd = Read-Host -AsSecureString
$domainCred = New-Object System.Management.Automation.PSCredential ("cloudpuzzles\Administrator", $passwd)
$localUser = New-Object System.Management.Automation.PSCredential ("Administrator", $passwd)

configuration HADC
{
    Import-DscResource -ModuleName xActiveDirectory

    Node $AllNodes.Where{$_.Role -eq "Primary DC"}.Nodename
    {
        WindowsFeature ADInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xADDomain FirstDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            SafemodeAdministratorPassword = $domaincred
            DependsOn = "[WindowsFeature]ADInstall"
        }

        xWaitForADDomain WaitDomain
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domaincred
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[xADDomain]FirstDC"
        }

        xADUser CreateUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            UserName = "jesper"
            Password = $domainCred
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]WaitDomain"
        }

    }

    Node $AllNodes.Where{$_.Role -eq "Replica DC"}.Nodename
    {
        WindowsFeature ADInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain WaitDomain
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domaincred
	   		RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            SafemodeAdministratorPassword = $domaincred
            DependsOn = "[xWaitForADDomain]WaitDomain"
        }
    }
}

$config = Invoke-Expression (Get-content $PSScriptRoot\HADCconfiguration.psd1 -Raw)
HADC -configurationData $config

Start-DscConfiguration -Wait -Force -Verbose -ComputerName "DC01" -Path $PSScriptRoot\HADC -Credential $localcred
Start-DscConfiguration -Wait -Force -Verbose -ComputerName "DC02" -Path $PSScriptRoot\HADC -Credential $localcred