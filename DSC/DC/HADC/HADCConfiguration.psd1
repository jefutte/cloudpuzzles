@{
    AllNodes = @(

        @{
            Nodename = "dc01"
            Role = "PDC"
            DomainName = "cloudpuzzles.net"
            PSDscAllowPlainTextPassword = $true
	        RetryCount = 20 
	        RetryIntervalSec = 30 
        },

        @{
            Nodename = "dc02"
            Role = "RDC"
            DomainName = "cloudpuzzles.net"
            PSDscAllowPlainTextPassword = $true
	        RetryCount = 20 
	        RetryIntervalSec = 30 
        }
    )
}